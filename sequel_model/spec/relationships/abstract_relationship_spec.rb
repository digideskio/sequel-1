require File.join(File.dirname(__FILE__), "../spec_helper")

describe Sequel::Model::AbstractRelationship do
  describe "intance methods" do
    before :each do
      class Post < Sequel::Model(:posts); end
      @one = Sequel::Model::HasOneRelationship.new Post, :author, {:class => 'User'}
      @many = Sequel::Model::HasManyRelationship.new Post, :comments, {:force => true}
      @join_table = mock(Sequel::Model::JoinTable)
    end
    
    describe "create" do
      it "should call the create join table method" do
        @one.should_receive(:create_join_table).and_return(true)
        @one.should_receive(:define_accessor)
        @one.create
      end
    end
    
    describe "create_join_table" do
      before :each do
        @one.stub!(:define_accessor)
        @many.stub!(:define_accessor)
      end
      
      it "should create the table if it doesn't exist" do
        Post.should_receive(:table_name).and_return('posts')
        Sequel::Model::JoinTable.should_receive(:new).with('posts', 'authors').and_return(@join_table)
        @join_table.should_receive(:exists?).and_return(false)
        @join_table.should_receive(:create)
        @one.create_join_table
      end
      
      it "should force create the table when the option is specified" do
        Post.should_receive(:table_name).and_return('posts')
        Sequel::Model::JoinTable.should_receive(:new).with('posts', 'comments').and_return(@join_table)
        @join_table.should_receive(:exists?).and_return(true)
        @join_table.should_receive(:create!)
        @many.create_join_table
      end
    end
    
    describe "define_accessor" do
      it "should define a reader" do
        @one.define_accessor
        @one.should respond_to(:author)
        @many.define_accessor
        @many.should respond_to(:comments)
      end
      
      it "should define a writer" do
      end
    end
  end
end