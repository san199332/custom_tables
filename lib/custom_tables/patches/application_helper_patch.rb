module CustomTables
  module Patches
    module ApplicationHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method :format_object_without_customtables, :format_object
          alias_method :format_object, :format_object_with_customtables
        end
      end

      module InstanceMethods
        def format_object_with_customtables(object, html=true, &block)
           if block_given?
             object = yield object
           end
           case object.class.name
           when 'CustomValue', 'CustomFieldValue'
             if object.customized.class.name != "CustomEntity"
               return "" unless object.customized&.visible?
             end
             if object.custom_field
               f = object.custom_field.format.formatted_custom_value(self, object, html)
               if f.nil? || f.is_a?(String)
                 f
               else
                 format_object(f, html, &block)
               end
             else
               object.value.to_s
             end
           else
             html ? h(format_object_without_customtables(object, html=true, &block)) : format_object_without_customtables(object, html=false, &block).to_s
           end
        end
      end
    end
  end
end

unless ApplicationHelper.included_modules.include?(CustomTables::Patches::ApplicationHelperPatch)
  ApplicationHelper.send(:include, CustomTables::Patches::ApplicationHelperPatch)
end
