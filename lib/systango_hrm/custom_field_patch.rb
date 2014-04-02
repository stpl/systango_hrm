require_dependency 'custom_field'

module SystangoHrm
  module CustomFieldPatch
    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods

      def employee_code_custom_field
        CustomField.where(:name=> SystangoHrm::Constants::EMPLOYEE_CODE)
      end

    end
  end
end
