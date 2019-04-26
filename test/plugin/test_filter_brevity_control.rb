#Copyright 2019 - Nokia
##author: CLOG Team
##time: 2018.12.01

require 'helper'
require 'fluent/test/driver/filter'
require 'fluent/plugin/filter_brevity_control'

class BrevityControlFilterTest < Test::Unit::TestCase
  include Fluent

  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    interval  10
    num       2
    attr_keys host, message
  ]

  CONFIG_WITH_NESTED_KEY = %[
    interval  10
    num       2
    attr_keys data.host, data.message
  ]

  CONFIG_TAG_ONLY = %[
    interval 10
    num      2
  ]

  CONFIG_MAX_SLOT_NUM = %[
    interval       10
    num            2
    max_slot_num   3
    attr_keys      host, message
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::BrevityControlFilter).configure(conf)
  end

  def test_emit
    d = create_driver(CONFIG)
    es = Fluent::MultiEventStream.new

    time = event_time("2012-11-22 11:22:33 UTC")
    es.add(time + 1, {"id" => 1, "host" => "web01", "message" => "error!!"})
    es.add(time + 2, {"id" => 2, "host" => "web01", "message" => "error!!"})
    es.add(time + 3, {"id" => 3, "host" => "web01", "message" => "error!!"})
    es.add(time + 4, {"id" => 4, "host" => "web01", "message" => "error!!"})
    es.add(time + 4, {"id" => 5, "host" => "app01", "message" => "error!!"})
    es.add(time + 12, {"id" => 6, "host" => "web01", "message" => "error!!"})
    es.add(time + 13, {"id" => 7, "host" => "web01", "message" => "error!!"})
    es.add(time + 14, {"id" => 8, "host" => "web01", "message" => "error!!"})

    d.run(default_tag: "test.info") do
      d.feed(es)
    end
    records = d.filtered_records

    assert_equal 6, records.length
    assert_equal({"id" => 1, "host" => "web01", "message" => "error!!"}, records[0])
    assert_equal({"id" => 2, "host" => "web01", "message" => "error!!"}, records[1])
    assert_equal({"id" => 5, "host" => "app01", "message" => "error!!"}, records[2])
    assert_equal({"log"=>"brevity control drop 2 message(s), test.info, host=web01 | message=error!!"}, records[3])
    assert_equal({"id" => 6, "host" => "web01", "message" => "error!!"}, records[4])
    assert_equal({"id" => 7, "host" => "web01", "message" => "error!!"}, records[5])
  end

  def test_emit_wtih_nested_key
    d = create_driver(CONFIG_WITH_NESTED_KEY)
    es = Fluent::MultiEventStream.new

    time = event_time("2012-11-22 11:22:33 UTC")
    es.add(time + 1, {"id" => 1, "data" => {"host" => "web01", "message" => "error!!"}})
    es.add(time + 2, {"id" => 2, "data" => {"host" => "web01", "message" => "error!!"}})
    es.add(time + 3, {"id" => 3, "data" => {"host" => "web01", "message" => "error!!"}})
    es.add(time + 4, {"id" => 4, "data" => {"host" => "web01", "message" => "error!!"}})
    es.add(time + 4, {"id" => 5, "data" => {"host" => "app01", "message" => "error!!"}})
    es.add(time + 12, {"id" => 6, "data" => {"host" => "web01", "message" => "error!!"}})
    es.add(time + 13, {"id" => 7, "data" => {"host" => "web01", "message" => "error!!"}})
    es.add(time + 14, {"id" => 8, "data" => {"host" => "web01", "message" => "error!!"}})

    d.run(default_tag: "test.info") do
      d.feed(es)
    end
    records = d.filtered_records

    assert_equal 6, records.length
    assert_equal({"id"=>1, "data" => {"host"=>"web01", "message"=>"error!!"}}, records[0])
    assert_equal({"id"=>2, "data" => {"host"=>"web01", "message"=>"error!!"}}, records[1])
    assert_equal({"id"=>5, "data" => {"host"=>"app01", "message"=>"error!!"}}, records[2])
    assert_equal({"log"=>"brevity control drop 2 message(s), test.info, data.host=web01 | data.message=error!!"}, records[3])
    assert_equal({"id"=>6, "data" => {"host"=>"web01", "message"=>"error!!"}}, records[4])
    assert_equal({"id"=>7, "data" => {"host"=>"web01", "message"=>"error!!"}}, records[5])
  end

  def test_emit_tagonly
    d = create_driver(CONFIG_TAG_ONLY)
    es = Fluent::MultiEventStream.new

    time = event_time("2012-11-22 11:22:33 UTC")
    es.add(time + 1, {"id" => 1, "host" => "web01", "message" => "1 error!!"})
    es.add(time + 2, {"id" => 2, "host" => "web02", "message" => "2 error!!"})
    es.add(time + 3, {"id" => 3, "host" => "web03", "message" => "3 error!!"})
    es.add(time + 4, {"id" => 4, "host" => "web04", "message" => "4 error!!"})
    es.add(time + 4, {"id" => 5, "host" => "app05", "message" => "5 error!!"})
    es.add(time + 12,{"id" => 6, "host" => "web06", "message" => "6 error!!"})
    es.add(time + 13,{"id" => 7, "host" => "web07", "message" => "7 error!!"})
    es.add(time + 14,{"id" => 8, "host" => "web08", "message" => "8 error!!"})

    d.run(default_tag: "test.info") do
      d.feed(es)
    end
    records = d.filtered_records

    assert_equal 5, records.length
    assert_equal({"id"=>1, "host"=>"web01", "message"=>"1 error!!"}, records[0])
    assert_equal({"id"=>2, "host"=>"web02", "message"=>"2 error!!"}, records[1])
    assert_equal({"log"=>"brevity control drop 3 message(s), test.info"}, records[2])
    assert_equal({"id"=>6, "host"=>"web06", "message"=>"6 error!!"}, records[3])
    assert_equal({"id"=>7, "host"=>"web07", "message"=>"7 error!!"}, records[4])
  end

  def test_emit_max_slot_num
    d = create_driver(CONFIG_MAX_SLOT_NUM)
    es = Fluent::MultiEventStream.new

    time = event_time("2012-11-22 11:22:33 UTC")
    es.add(time + 1,  {"id" => 1, "host" => "web01", "message" => "1 error!!"})
    es.add(time + 2,  {"id" => 2, "host" => "web02", "message" => "2 error!!"})
    es.add(time + 3,  {"id" => 3, "host" => "web03", "message" => "3 error!!"})
    es.add(time + 4,  {"id" => 4, "host" => "web01", "message" => "1 error!!"})
    es.add(time + 5,  {"id" => 5, "host" => "web04", "message" => "4 error!!"})
    es.add(time + 6,  {"id" => 6, "host" => "web01", "message" => "1 error!!"})

    d.run(default_tag: "test.info") do
      d.feed(es)
    end
    records = d.filtered_records

    assert_equal 6, records.length
    assert_equal({"id"=>1, "host"=>"web01", "message"=>"1 error!!"}, records[0])
    assert_equal({"id"=>2, "host"=>"web02", "message"=>"2 error!!"}, records[1])
    assert_equal({"id"=>3, "host"=>"web03", "message"=>"3 error!!"}, records[2])
    assert_equal({"id"=>4, "host"=>"web01", "message"=>"1 error!!"}, records[3])
    assert_equal({"id"=>5, "host"=>"web04", "message"=>"4 error!!"}, records[4])
    assert_equal({"id"=>6, "host"=>"web01", "message"=>"1 error!!"}, records[5])
  end
end
