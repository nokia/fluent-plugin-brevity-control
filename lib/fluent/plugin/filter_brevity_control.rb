#Copyright 2019 - Nokia
#author: CLOG Team
#time: 2018.12.01

require 'fluent/plugin/filter'

module Fluent::Plugin
  class BrevityControlFilter < Fluent::Plugin::Filter
    Fluent::Plugin.register_filter('brevity_control', self)

    config_param :attr_keys,     :string,  default: nil
    config_param :num,           :integer, default: 3
    config_param :max_slot_num,  :integer, default: 100000
    config_param :interval,      :integer, default: 300
    config_param :stats_msg_tag, :string, default: nil
    config_param :stats_msg_fields, :string, default: nil
    config_param :all_keys_used,   :bool, default: true
    
    def configure(conf)
      super
      @keys  = @attr_keys ? @attr_keys.split(/ *, */) : nil
      @fields = @stats_msg_fields ? @stats_msg_fields.split(/ *, */) : nil
      @slots = {}
    end

    def filter_stream(tag, es)
      new_es = Fluent::MultiEventStream.new
      es.each do |time, record|
        #log.debug "receive record: " + record.to_s
        #log.debug "hash : " + @slots.to_s
        if @keys
          values = @keys.map do |key|
            value=key.split(/\./).inject(record) do |r, k|
              break unless r.has_key?(k)
              r[k]
            end
            if value.class != String
              value = value.to_s
            end
            value ? key+"="+value : nil
          end
          if @all_keys_used
            if values.include? nil
              new_es.add(time, record)
              next
            end
          end
          values = values.compact()
          if values.size > 0
            key = tag + ", " + values.join(" | ")
          else
            new_es.add(time, record)
            next
          end
        else
          key = tag
        end
        slot = @slots[key] ||= {:emit_time=>[],:drop_num=>0,:timestamp=>""}

        # expire old records time
        expired = time.to_f - @interval
        while slot[:emit_time].first && (slot[:emit_time].first <= expired)
          slot[:emit_time].shift
        end

        if slot[:emit_time].length >= @num
          slot[:drop_num] += 1
          slot[:timestamp] = Time.now.to_datetime.rfc3339
          next
        end

        if @slots.length > @max_slot_num
          (evict_key, evict_slot) = @slots.shift
          if evict_slot[:emit_time].last && (evict_slot[:emit_time].last > expired)
            log.debug "@slots length exceeded @max_slot_num: #{@max_slot_num}. Evicted slot for the key: #{evict_key}"
          end
          #send_stat_log(new_es, time, evict_key, evict_slot)
        end
        send_stat_log(new_es, time, key, slot, record)

        slot[:emit_time].push(time.to_f)
        new_es.add(time, record)
      end
      return new_es
    end

    def send_stat_log(es, time, key, value, record)
      if (value[:drop_num] <= 0)
        return
      end

      if @stats_msg_tag
        router.emit(@stats_msg_tag, time, stat_log(key, value, record))
      else
        es.add(time,stat_log(key, value, record))
      end
    end


    def stat_log(key, value, record)
      message="brevity control drop #{value[:drop_num]} message(s), #{key}"
      log = {"level"=>"info",
        "log"=>{"message"=>message},
        "time"=>value[:timestamp],
        "type"=>"log"}
      if @fields
          @fields.map do |field|
            if record[field]
              log[field]=record[field].clone
            end
          end
      end
      value[:drop_num] = 0
      log
    end

  end
end

