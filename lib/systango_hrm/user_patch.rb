require_dependency 'user'

module SystangoHrm
  module UserPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)
      base.class_eval do
        unloadable

        scope :users_with_admin_permissions,-> { where(admin: true)}
        scope :locked_users, ->{where(status: SystangoHrm::Constants::STATUS_LOCKED)}
        scope :active_users, ->{where(status: SystangoHrm::Constants::STATUS_ACTIVE)}
        scope :active_users_to_add, ->(user_id){where("id not in (?) AND status = ?", user_id, SystangoHrm::Constants::STATUS_ACTIVE)}
        scope :subordinates_to_add_or_remove, ->(user_id, username ){ where("id in (?) AND (firstname LIKE ? or lastname LIKE ?)",user_id,"%#{username}%","%#{username}%")}
        scope :order_by_firstname_asc,-> {order("firstname asc")}

        has_many :systango_hrm_compoffs, dependent: :destroy
        has_one :systango_hrm_leave_account, dependent: :destroy
        has_one :systango_hrm_leave_summary_current_year, dependent: :destroy
        has_many :self_employee_leaves, :class_name => "SystangoHrmEmployeeLeave", :foreign_key => 'user_id',:conditions => {:referral_id =>nil}, dependent: :destroy
        has_many :referred_employee_leaves, :class_name => "SystangoHrmEmployeeLeave", :foreign_key => 'referral_id', dependent: :destroy
        has_many :systango_hrm_designation_histories, dependent: :destroy
        has_many :teamleads, :class_name => "SystangoHrmTeamleadsSubordinates", :foreign_key => 'teamlead_user_id', dependent: :destroy
        has_many :subordinates, :class_name => "SystangoHrmTeamleadsSubordinates", :foreign_key => 'subordinate_user_id', dependent: :destroy
        has_many :systango_hrm_request_receiver, :class_name => "SystangoHrmRequestReceiver", :foreign_key => 'receiver_id', dependent: :destroy
      end
    end
    
    module InstanceMethods
      def admin_user?
        (self.admin or self.allowed_to_globally?(:hr_permissions, {}) rescue false)
      end
    end

    module ClassMethods
      def users_with_hr_permission
        Role.all.inject([]) do |result, role| 
          result << role.members.map(&:user) if role.has_permission?(:hr_permissions)
          result
        end.flatten.uniq rescue nil
      end
      
      def admin_user?(user)
        admin_users.map(&:id).include?(user.id) rescue false
      end

      def admin_users
        ((self.users_with_hr_permission || []) + 
          (self.users_with_admin_permissions || [] )).uniq
      end
      
      #[TODO] : Confirm with Ankur Sir
      # def remove_locked_users_from_array(users)
      #   # code breaked when users is nil/blank.
      #   (users - (self.locked_users rescue [])) rescue []
      # end

      def remove_leaves_of_locked_users(leaves_list)
        return leaves_list if self.locked_users.blank?
        locked_users_id = self.locked_users.map(&:id)
        employee_leave_of_locked_users = []
        leaves_list.map(&:user_id).each{ |id| employee_leave_of_locked_users << SystangoHrmEmployeeLeave.by_user_id(id) if locked_users_id.include?(id) }
        leaves_list.map(&:referral_id).each{ |r_id| employee_leave_of_locked_users << SystangoHrmEmployeeLeave.by_referral_id(r_id) if locked_users_id.include?(r_id) }
        leaves_list - (employee_leave_of_locked_users.flatten.uniq rescue [])
      end

      def active_users_without_leave_account
        ((SystangoHrmLeaveAccount.count rescue 0 ) == 0) ? self.active_users : self.active_users_to_add(SystangoHrmLeaveAccount.all.map(&:user_id))
      end

      def get_email_for_users(user_ids)
        user_ids.collect {|id| (User.find(id).mail rescue nil) }
      end

    end
  end
end
