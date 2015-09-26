require 'missle/validatable'
require 'wepo/adapters/active_record'

module Missle
  module Crud

    def self.included(base)
      base.instance_eval do
        extend Uber::InheritableAttr
        inheritable_attr :repo_class

        self.repo_class = nil

        def repo(*args)
          if args[0]
            self.repo_class = args[0]
          else
            self.repo_class
          end
        end
      end
    end

    def repo
      @repo ||= self.class.repo_class.new(adapter: Wepo::Adapters::ActiveRecord.new)
    end

    attr_reader :adapter

    def find(id)
      repo.find(id)
    end

    def save(entity)
      repo.save(entity)
    end

    def create(entity)
      repo.save(entity)
    end

    def update(entity, attributes)
      repo.update(entity, attributes)
    end

    def delete(entity)
      repo.delete(entity)
    end

    def new_entity
      entity_class.new
    end
  end
end
