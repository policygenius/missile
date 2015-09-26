require 'spec_helper'
require 'wepo'


module Missle
  describe Crud do
    let!(:repo) { double(:repo, save: true) }
    let!(:repo_class) { double(:repo_class) }
    let!(:entity_class) { double(:entity_class) }
    let!(:entity) { double(:entity, name: true) }

    before do
      allow(entity_class).to receive(:new).and_return(entity)
    end

    describe '#find' do
      let(:subclass) do
        mock_repo_class = repo_class

        Class.new(Missle::Command) do
          include Crud
          repo mock_repo_class

          def run
            success! find(1)
            self
          end
        end

      end

      let(:command) { subclass.new({}) }

      before do
        allow(repo_class).to receive(:new) { repo }
      end

      it 'send the #find message to the repo' do
        expect(command.repo).to receive(:find).with(1)
        command.run
      end

      it 'broadcasts the success message' do
        allow(command.repo).to receive(:find).with(1)
        expect { command.run }.to broadcast(:success)
      end
    end

    describe '#create' do
      let(:subclass) do
        mock_repo_class = repo_class
        MockEntityClass = entity_class
        Class.new(Missle::Command) do
          include Crud
          include Validatable

          repo mock_repo_class

          contract do
            property :name
            validates :name, presence: true
          end

          def run
            validate(params, MockEntityClass.new) do |entity|
              if create(entity)
                success! entity
              else
                fail! entity.errors
              end
            end
            self
          end
        end
      end
      let(:command) { subclass.new({name: 'test'}) }

      before do
        allow(repo_class).to receive(:new).and_return(repo)
        allow(entity).to receive(:name=).with('test')
      end

      it 'sends the #save message to the repo' do
        expect(entity).to receive(:name=).with('test')
        expect(repo).to receive(:save).with(entity)
        command.run
      end

      context 'when successful' do
        it 'broadcasts the success message' do
          allow(repo).to receive(:save).with(entity) { true }
          expect { command.run }.to broadcast(:success, entity)
        end
      end
      context 'when failed' do

        let(:command) { subclass.new({name: nil}) }

        context 'when validation failed' do
          it 'broadcasts the failed message' do
            expect { command.run }.to broadcast(:failure, { errors: { name: ["can't be blank"] } })
          end
        end
      end
    end
  end
end
