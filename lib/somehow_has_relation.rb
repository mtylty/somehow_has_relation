require 'active_record'

module SomehowHasRelation
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def somehow_has(params={})
      if class_variable_defined? :@@somehow_has_relation_options
        class_variable_set(:@@somehow_has_relation_options, class_variable_get(:@@somehow_has_relation_options) << params)
      else
        class_variable_set(:@@somehow_has_relation_options, [params])
      end

      somehow_has_relation_options = class_variable_get(:@@somehow_has_relation_options)
      times_defined = somehow_has_relation_options.count
      current_options = somehow_has_relation_options[times_defined-1]

      relation = current_options[:one] || current_options[:many]
      default_method_name = "related_#{relation}"

      related = current_options[:as] || default_method_name

      # Dynamic Instance Method related_%{relation_name}
      define_method(related) do
        found = somehow_found_or_recur relation, current_options[:if], current_options
        if current_options.has_key?(:one)
          found.flatten.compact.first rescue found
        elsif current_options.has_key?(:many)
          found.flatten.compact rescue []
        end
      end
    end
  end

  module InstanceMethods
    def somehow_recur(relation, through, filter)
      first_step = send_and_filter(through)

      if first_step.is_a? Array
        first_step.map{|instance| instance.somehow_found_or_recur(relation, filter)}
      else
        first_step.somehow_found_or_recur(relation, filter)
      end
    end

    def somehow_found_or_recur(relation, condition=nil, opts=nil)
      if self.class.send(:class_variable_defined?, :@@somehow_has_relation_options)
        opts ||= self.class.send(:class_variable_get, :@@somehow_has_relation_options)
        opts = [opts] unless opts.is_a? Array

        found = []

        opts.each do |opt|
          begin
            if opt.has_key?(:through)
              found << somehow_recur(relation, opt[:through], opt[:if])
            else
              return send_and_filter(relation, condition)
            end
          rescue
            found << []
          end
        end

        found
      else
        send_and_filter(relation, condition)
      end
    end

    private

    def send_and_filter(method, filter_proc=nil)
      filter_proc ? filter_relations_with(send(method), filter_proc) : send(method)
    end

    def filter_relations_with(to_filter, filter_proc)
      if to_filter.is_a? Array
        to_filter.select(&filter_proc)
      elsif filter_proc.to_proc.call(to_filter)
        to_filter
      end
    end
  end
end

ActiveRecord::Base.send :include, SomehowHasRelation
