require 'test_helper'

class SomehowHasRelationTest < ActiveSupport::TestCase
  setup do
    Post.somehow_has
  end

  test "somehow_has_relation is a Module" do
    assert_kind_of Module, SomehowHasRelation
  end

  test "ActiveRecord::Base should have a somehow_has method" do
    assert ActiveRecord::Base.methods.include? :somehow_has.to_s
  end

  test "when somehow_has is called, it should define SOMEHOW_HAS_RELATION" do
    assert Post.const_defined?('SOMEHOW_HAS_RELATION')
  end

  test "an Hash of parameters should be passed to somehow_has" do
    assert_equal Hash, Post::SOMEHOW_HAS_RELATION.class
  end

  test "reinitialize when somehow_has is called more than once" do
    params = {:newparam => 'newvalue'}
    Post.somehow_has params
    assert_equal params, Post::SOMEHOW_HAS_RELATION
  end

  test "relations should work even when somehow_has has not been defined for first step" do
    @post = Post.create(:author => Author.create, :comments => [Comment.create, Comment.create])

    assert_equal @post.author, @post.related_author
    assert_equal @post.comments, @post.related_comments
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
    assert_equal [comments1, comments2], @author.related_comments
  end

  test "3-steps relations should work just like 2-steps and n-steps relations" do
    comments1, comments2 = [Comment.create, Comment.create], [Comment.create, Comment.create]
    posts = [Post.create(:comments => comments1), Post.create(:comments => comments2)]
    author = Author.create(:posts => posts)
    @bio = Bio.create(:author => author)

    Post.somehow_has :many => :comments
    Author.somehow_has :many => :comments, :through => :posts
    Bio.somehow_has :many => :comments, :through => :author
    assert_equal [comments1, comments2], @bio.related_comments
  end
end
