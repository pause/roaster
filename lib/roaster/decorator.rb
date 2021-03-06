require 'representable/decorator'


module Roaster

  class Decorator < Representable::Decorator

    def resource_id
      self.represented.attributes['id']
    end

    class << self

      def strip(doc)
        doc[get_resource_name] || doc
      end

      def has_one(name, as: as, mapping: mapping)
      #TODO: Maybe store rels in a single hash, preventing conflicts and solving difficult access (add a type key)
        representable_attrs[:_has_one] ||= []
        property name, as: as
        as ||= name
        representable_attrs[:_has_one].push({as: as, name: name, mapping: mapping })
      end

      #PING: Overriding build_definition is maybe required
      def has_many(name, as: as, mapping: mapping)
        representable_attrs[:_has_many] ||= []
        collection name, as: as
        as ||= name
        representable_attrs[:_has_many].push({as: as,  name: name, mapping: mapping})
      end

      def can_filter_by(*attrs)
        representable_attrs[:_filterable_attributes] ||= []
        representable_attrs[:_filterable_attributes].push(*attrs.map(&:to_sym)).uniq!
      end

      def filterable_attributes
        representable_attrs[:_filterable_attributes] ||= []
        representable_attrs[:_filterable_attributes]
      end

      #TODO: Disallow sorting directly by relationship (need relationship field)
      def can_sort_by(*attrs)
        representable_attrs[:_sortable_attributes] ||= []
        sort_keys = attrs.map do |option|
          if option.class == Hash
            { option.first[0].to_sym => option.first[1].map(&:to_sym) }
          else
            option.to_sym
          end
        end
        representable_attrs[:_sortable_attributes].push(*sort_keys).uniq!
      end

      def sortable_attributes
        representable_attrs[:_sortable_attributes] ||= []
        representable_attrs[:_sortable_attributes]
      end

      def can_include(*attrs)
        representable_attrs[:_includeable_attributes] ||= []
        representable_attrs[:_includeable_attributes].push(*attrs.map(&:to_sym)).uniq!
      end

      def includeable_attributes
        representable_attrs[:_includeable_attributes] ||= []
        representable_attrs[:_includeable_attributes]
      end

      def get_resource_name
        if defined? @@overloaded_resource_name
          @@overloaded_resource_name
        else
          self.to_s.gsub(/Mapping\Z/, '').underscore.pluralize
        end
      end

      def resource_name(name)
        @@overloaded_resource_name = name
      end

    end

  end

end
