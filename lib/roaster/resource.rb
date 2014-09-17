module Roaster

  class Resource

    def initialize(adapter_class, opts = {})
      @adapter = adapter_class.new
      @model_class = opts[:model_class]
    end

    def new(query)
      @adapter.new(query)
    end

    def save(model)
      @adapter.save(model)
      model
    end

    def delete(query)
      @adapter.delete(query)
    end

    def create_relationship(query, document)
      @adapter.create_relationship(query, document)
    end

    def update_relationships(query, document)
      @adapter.update_relationship(query, document)
    end

    def find(query)
      @adapter.find(query, model_class: @model_class)
    end

    def query(query)
      @adapter.read(query, model_class: @model_class)
    end

  end

end
