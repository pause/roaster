require 'minitest/autorun'

require 'roaster/query'
require 'roaster/resource'
require 'roaster/request'

require_relative 'test_helper'
require_relative 'factories/album'

class PoniesTest < MiniTest::Test

  def setup
    super
    #TODO: Replace this by fixtures
    FactoryGirl.create(:animals_album)
    FactoryGirl.create(:the_wall_album)
    FactoryGirl.create(:meddle_album)
    @arch_enemy_band = FactoryGirl.create :band, name: 'Arch Enemy'
    @wages_of_sin_album = FactoryGirl.create :album, title: 'Wages of Sin', band: @arch_enemy_band
    @ar_resource = Roaster::Resource.new(Roaster::Adapters::ActiveRecord)
                              #model_class: ::Blog::Category
  end

  def build_target(resource_name = :albums, resource_ids = nil, relationship_name = nil, relationship_ids = nil)
    Roaster::Query::Target.new(resource_name, resource_ids, relationship_name, relationship_ids)
  end

  def build_request(operation, target: build_target, resource: @ar_resource, params: {}, document: nil)
    Roaster::Request.new(operation,
                         target,
                         resource,
                         params,
                         document: document)
  end

  def test_ponies
    rq = build_request(:read)
    res = rq.execute
    assert_equal([{'title' => 'Animals'}, {'title' => 'The Wall'}, {'title' => 'Meddle'}, {'title' => 'Wages of Sin'}], res)
  end

  def test_sorted_ponies
    params = {sort: :title}
    rq = build_request(:read, params: params)
    res = rq.execute
    assert_equal([{'title' => 'Animals'}, {'title' => 'Meddle'}, {'title' => 'The Wall'}, {'title' => 'Wages of Sin'}], res)
  end

  def test_simple_filtered_ponies
    params = {title: 'Animals'}
    rq = build_request(:read, params: params)
    res = rq.execute
    assert_equal([{'title' => 'Animals'}], res)
  end

  #TODO: Make this one pass !
  def test_association_filtered_ponies
    return
    params = {
      band: {
        name: @arch_enemy_band.name
      }
    }
    rq = build_request(:read, params: params)
    res = rq.execute
    assert_equal 1, res.count
    assert_equal @arch_enemy_band.name, res.first.band.name
  end

  def test_create_pony
    album_hash = {
      'title' => 'The Downward Spiral'
    }
    rq = build_request(:create, document: album_hash)

    res = rq.execute
    refute_nil res.id
    assert_equal 'The Downward Spiral', res.title
  end

  def test_update_pony
    album = FactoryGirl.create(:album)
    album_update_hash = {
      'title' => 'Antichrist Superstar'
    }
    target = build_target(:albums, album.id)
    rq = build_request(:update, target: target, document: album_update_hash)

    res = rq.execute
    assert_equal album.id, res.id
    assert_equal 'Antichrist Superstar', res.title
  end

  def test_delete_pony
    album = FactoryGirl.create(:album)
    album_id = album.id
    target = build_target(:albums, album_id)
    rq = build_request(:delete)

    res = rq.execute
    refute Album.exists?(album_id)
  end

end
