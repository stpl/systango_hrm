module SystangoHrm
	module ContextMenu
    def self.included(klass)
      klass.instance_eval do
        def generate_context_menu(context)
          define_method :context_menu do
            #added titleize.gsub to convert the variables like 'leave_account'
            context_klass = eval("SystangoHrm#{context.camelize}")
            self.instance_variable_set("@#{context}s", context_klass.send(:find, params["selected_#{context}s"]))   
            context_val = self.instance_variable_get("@#{context}s")
            self.instance_variable_set("@#{context}", context_val.first) if context_val.size == 1
            @can = {:edit => true}
            render :layout => false
          end
        end
      end
    end
  end
end