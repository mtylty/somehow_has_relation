require 'active_record'

module SomehowHasRelation
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def somehow_has(params={})
      remove_const('SOMEHOW_HAS_RELATION') if const_defined?('SOMEHOW_HAS_RELATION')
      const_set('SOMEHOW_HAS_RELATION', params)

      prefix = "related"
      filter = params[:if]
      relation = params[:one] || params[:many]
      related = params[:as] || "#{prefix}_#{relation}"
      to_flatten = params[:through] && params[:many]

      # Dynamic Instance Method related_%{relation_name}
      define_method(related) do
        begin
          somehow_got = params[:through] ? somehow_look_for(relation, params[:through]) : send_and_filter(relation, filter)
          to_flatten ? somehow_got.flatten : somehow_got
        rescue
          [] if params[:many]
        end
      end
    end

    def somehow_has_options(key=nil)
      if const_defined?('SOMEHOW_HAS_RELATION')
        key ? const_get('SOMEHOW_HAS_RELATION')[key] : const_get('SOMEHOW_HAS_RELATION')
      end
    end
  end

  module InstanceMethods
    def somehow_look_for(relation, through)
      first_step = send_and_filter(through)
      condition = self.class.somehow_has_options(:if)

      if first_step.is_a? Array
        first_step.map{|instance| instance.somehow_keep_looking_for(relation, condition)}
      else
        first_step.somehow_keep_looking_for(relation, condition)
      end
    end

    def somehow_keep_looking_for(relation, condition=nil)
      if self.class.somehow_has_options :through
        somehow_look_for(relation, self.class.somehow_has_options(:through))
      else
        condition.nil? ? send_and_filter(relation) : send_and_filter(relation, condition)
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
