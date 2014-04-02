require_dependency 'custom_value'

module SystangoHrm
  module CustomValuePatch
    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      
      def value_employee_code(user)
        custom_field = CustomField.employee_code_custom_field
        CustomValue.where("custom_field_id = ? and customized_id =?", custom_field.first.id, user.id).first unless custom_field.blank? rescue nil
      end

    end
  end
end
