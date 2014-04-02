require 'systango_hrm/user_patch'

module SystangoHrm
  def self.apply_patch
    User.send(:include, UserPatch)
    WelcomeHelper.send(:include, WelcomeHelperPatch)
    CustomField.send(:include, CustomFieldPatch)
    CustomValue.send(:include, CustomValuePatch)
  end
end
