module SystangoHrm
  module CachedModel
    def self.included(klass)
      klass.extend(ClassMethods)
      klass.send(:after_save, :update_cache)
    end

    def update_cache
        self.class.update_cache
    end

    module ClassMethods
      def get_static_cache(reload = false)
        @static_cache=nil if reload
        @static_cache ||= begin
            h=Hash.new
            self.all.each do |rec|
                rec.freeze
                h[rec.id]=rec
            end
            h.freeze
            h
        end
      end

      def all_as_array
        get_static_cache.values
      end

      def update_cache
        get_static_cache(true)
      end
    end
  end
end