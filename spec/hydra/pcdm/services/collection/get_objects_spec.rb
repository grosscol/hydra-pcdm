require 'spec_helper'

describe Hydra::PCDM::GetObjectsFromCollection do

  subject { Hydra::PCDM::Collection.new }

  let(:collection1) { Hydra::PCDM::Collection.new }
  let(:collection2) { Hydra::PCDM::Collection.new }

  let(:object1) { Hydra::PCDM::Object.new }
  let(:object2) { Hydra::PCDM::Object.new }

  describe '#call' do
    it 'should return empty array when no members' do
      expect(Hydra::PCDM::GetObjectsFromCollection.call( subject )).to eq []
    end

    it 'should return empty array when only collections are aggregated' do
      Hydra::PCDM::AddCollectionToCollection.call( subject, collection1 )
      Hydra::PCDM::AddCollectionToCollection.call( subject, collection2 )
      expect(Hydra::PCDM::GetObjectsFromCollection.call( subject )).to eq []
    end

    context 'with collections and objects' do
      before do
        Hydra::PCDM::AddCollectionToCollection.call( subject, collection1 )
        Hydra::PCDM::AddCollectionToCollection.call( subject, collection2 )
        Hydra::PCDM::AddObjectToCollection.call( subject, object1 )
        Hydra::PCDM::AddObjectToCollection.call( subject, object2 )
      end

      it 'should only return related objects' do
        expect(Hydra::PCDM::GetObjectsFromCollection.call( subject )).to eq [object1,object2]
      end
    end
  end

  context 'with unacceptable inputs' do
    before(:all) do
      @object101       = Hydra::PCDM::Object.new
      @file101         = Hydra::PCDM::File.new
      @non_PCDM_object = "I'm not a PCDM object"
      @af_base_object  = ActiveFedora::Base.new
    end

    context 'that are unacceptable parent collections' do
      let(:error_message) { 'parent_collection must be a pcdm collection' }

      it 'should NOT accept Hydra::PCDM::Objects as parent collection' do
        expect{ Hydra::PCDM::GetObjectsFromCollection.call( @object101 ) }.to raise_error(ArgumentError,error_message)
      end

      it 'should NOT accept Hydra::PCDM::Files as parent collection' do
        expect{ Hydra::PCDM::GetObjectsFromCollection.call( @file101 ) }.to raise_error(ArgumentError,error_message)
      end

      it 'should NOT accept non-PCDM objects as parent collection' do
        expect{ Hydra::PCDM::GetObjectsFromCollection.call( @non_PCDM_object ) }.to raise_error(ArgumentError,error_message)
      end

      it 'should NOT accept AF::Base objects as parent collection' do
        expect{ Hydra::PCDM::GetObjectsFromCollection.call( @af_base_object ) }.to raise_error(ArgumentError,error_message)
      end
    end
  end
end
