module Roaster
  class Query

    #TODO: Find something better to do that
    #TODO: Move target name in here maybe ? (and init db adapter with this) =)
    class Target

      attr_accessor :ids, :relationship_name, :relationship_ids

      def initialize(ids = [], relationship_name = nil, relationship_ids = [])
        @ids = ids
        @relationship_name = relationship_name
        @relationship_ids = relationship_ids
      end

    end

    #TODO: This is not validating includes it seems (HARD VALIDATE EVERYTHING, raise is your FRIEND)
    attr_accessor :page, :page_size, :include, :filters, :mapping,
                  :include_links,
                  :sorting,
                  :target

    #TODO: Move in config class
    DEFAULT_PAGE_SIZE = 10

    def initialize(mapping, target, params = {})
      params.symbolize_keys! if params.respond_to?(:symbolize_keys!)

      @page = params[:page] ? params[:page].to_i : 1
      @page_size = params[:page_size] ? params[:page_size].to_i : DEFAULT_PAGE_SIZE
      @include = includes_from_params(params, mapping)
      @filters = filters_from_params(params, mapping)
      @sorting = sorting_from_params(params, mapping)
      #VALIDATE THIS (TARGET) ! omgz =D
      @mapping = mapping
      @target = target
      @include_links = true
    end

    def default_page_size?
      @page_size == DEFAULT_PAGE_SIZE
    end

    def filters_as_url_params
      @filters.sort.map { |k,v| map_filter_ids(k,v) }.join('&')
    end

    def sorting_as_url_params
      sorting_values = sorting.map { |k, v| v == :asc ? k : "-#{k}" }.join(',')
      "sort=#{sorting_values}"
    end

    private

    def includes_from_params(params, mapping)
      return [] unless params[:include] && params[:include].respond_to?(:split)
      includes = params[:include].split(',').map(&:to_sym)
      includes.select do |i|
        mapping.includeable_attributes.include?(i)
      end
    end

    def filters_from_params(params, mapping)
      filters = {}
      mapping.filterable_attributes.each do |filter|
        [filter, "#{filter}s".to_sym].each do |key|
          filters[filter] = params[key].to_s.split(',') if params[key]
        end
      end
      filters
    end

    def sorting_from_params(params, mapping)
      sort_values = params[:sort] && params[:sort].split(',')
      return {} if sort_values.blank? || mapping.serializable_sorting_attributes.blank?
      sorting_parameters = {}

      sort_values.each do |sort_value|
        sort_order = sort_value[0] == '-' ? :desc : :asc
        sort_value = sort_value.gsub(/\A\-/, '').downcase.to_sym
        sorting_parameters[sort_value] = sort_order if mapping.serializable_sorting_attributes.include?(sort_value)
      end
      sorting_parameters
    end

    def map_filter_ids(key,value)
      case value
      when Hash
        value.map { |k,v| map_filter_ids(k,v) }
      else
         "#{key}=#{value.join(',')}"
      end
    end

    def query_to_array(value)
      case value
        when String
          value.split(',')
        when Hash
          value.each { |k, v| value[k] = query_to_array(v) }
        else
          value
      end
    end
  end
end
