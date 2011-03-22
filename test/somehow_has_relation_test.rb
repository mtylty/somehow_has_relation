require 'test_helper'

class SomehowHasRelationTest < ActiveSupport::TestCase
  setup :init_somehow_has
  teardown :destroy_somehow_has

  test "somehow_has_relation is a Module" do
    assert_kind_of Module, SomehowHasRelation
  end

  test "ActiveRecord::Base should have a somehow_has method" do
    assert ActiveRecord::Base.methods.include? :somehow_has.to_s
  end

  test "when somehow_has is called, it should define @@somehow_has_relation_options" do
    assert Post.class_variable_defined?(:@@somehow_has_relation_options)
  end

  test "an Array of Hash of parameters should be passed to somehow_has" do
    params = {:newparam => 'newvalue'}
    Post.somehow_has params

    assert_equal Array, Post.send(:class_variable_get, :@@somehow_has_relation_options).class
    assert_equal Hash, Post.send(:class_variable_get, :@@somehow_has_relation_options).first.class
    assert_equal params, Post.send(:class_variable_get, :@@somehow_has_relation_options).last
  end

  test "relations should work even when somehow_has has not been defined for first step" do
    destroy_somehow_has
    comments = [Comment.create, Comment.create]
    post = Post.create(:comments => comments)
    @author = Author.create(:posts => [post])

    Author.somehow_has :many => :comments, :through => :posts
    assert_equal post.comments, @author.related_comments
  end

  test "1-step relation defines a method prefixed with related_ for standard associations methods" do
    @post = Post.create(:author => Author.create, :comments => [Comment.create, Comment.create])

    Post.somehow_has :one => :author
    assert_equal @post.author, @post.related_author

    Post.somehow_has :many => :comments
    assert_equal @post.comments, @post.related_comments
  end

  test "1-step relations also looks for belongs_to associations (with :has_one)" do
    @bio = Bio.create(:author => Author.create)

    Bio.somehow_has :one => :author
    assert_equal @bio.author, @bio.related_author
  end

  test "2-steps relations use :through and define a related_ prefixed method named as the last association" do
    comments = [Comment.create, Comment.create]
    @author = Author.create(:bio => Bio.create(:comments => comments))

    Author.somehow_has :many => :comments, :through => :bio
    assert_equal comments, @author.related_comments
  end

  test "2-steps relations should return an array of arrays when there are nested has_many associations" do
    comments1, comments2 = [Comment.create, Comment.create], [Comment.create, Comment.create]
    posts = [Post.create(:comments => comments1), Post.create(:comments => comments2)]
    @author = Author.create(:posts => posts)

    Post.somehow_has :many => :comments
    Author.somehow_has :many => :comments, :through => :posts
    assert_equal [comments1, comments2].flatten, @author.related_comments
  end

  test "3-steps relations should work just like 2-steps and n-steps relations" do
    comments1, comments2 = [Comment.create, Comment.create], [Comment.create, Comment.create]
    posts = [Post.create(:comments => comments1), Post.create(:comments => comments2)]
    author = Author.create(:posts => posts)
    @bio = Bio.create(:author => author)

    Post.somehow_has :many => :comments
    Author.somehow_has :many => :comments, :through => :posts
    Bio.somehow_has :many => :comments, :through => :author
    assert_equal [comments1, comments2].flatten, @bio.related_comments
  end

  test "somehow_has takes an :if argument which specifies a Proc to check against relations" do
    new_comment, old_comment = Comment.create, Comment.create
    old_comment.update_attribute :created_at, 1.day.ago
    recent_comments = Proc.new{|comment| comment.created_at >= 1.hour.ago }
    @author = Author.create(:posts => [Post.create(:comments => [new_comment, old_comment])])

    Author.somehow_has :many => :comments, :through => :posts, :if => recent_comments
    assert_equal [new_comment], @author.related_comments
  end

  test "somehow_has takes an :if argument which specifies a Symbol for a method that returns a boolean to check against relations" do
    new_comment, old_comment = Comment.create, Comment.create
    old_comment.update_attribute :created_at, 1.day.ago
    @author = Author.create(:posts => [Post.create(:comments => [new_comment, old_comment])])

    Author.somehow_has :many => :comments, :through => :posts, :if => :recent?
    assert_equal [new_comment], @author.related_comments
  end

  test "somehow_has takes an :as argument which overloads the defined related_%{relation_name} method name" do
    Post.somehow_has :many => :comments, :as => :blabla
    assert Post.instance_methods.include? :blabla.to_s
  end

  test ":if argument should also work for somehow_has :one" do
    @bio = Bio.create(:author => Author.create)

    Bio.somehow_has :one => :author, :if => Proc.new{|author| author.created_at <= 10.years.ago}
    assert_nil @bio.related_author
  end

  test "multiple somehow_has methods should define multiple recursive relations" do 
    comments1, comments2 = [Comment.create, Comment.create], [Comment.create, Comment.create]
    bio = Bio.create(:comments => comments1)
    @author = Author.create(:posts => [Post.create(:comments => comments2)], :bio => bio)

    Author.somehow_has :one => :bio
    Author.somehow_has :many => :comments, :through => :bio, :as => :related_bio_comments
    Author.somehow_has :many => :comments, :through => :posts, :as => :related_posts_comments
    assert_equal bio, @author.related_bio
    assert_equal comments1, @author.related_bio_comments
    assert_equal comments2, @author.related_posts_comments
  end

  test "when there is no :one related, return nil" do
    @post = Post.create
    Post.somehow_has :one => :author

    assert_nil @post.related_author
  end

  test "when there is no :many related, return []" do
    @post = Post.create
    Post.somehow_has :many => :comments

    assert_equal [], @post.related_comments
  end

  private

  def models
    [Post, Author, Bio, Comment]
  end

  def init_somehow_has
    models.each do |model|
      model.somehow_has
    end
  end

  def destroy_somehow_has
    models.each do |model|
      model.send(:remove_class_variable, :@@somehow_has_relation_options) rescue next
    end
  end
end
