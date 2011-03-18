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
      relation = params[:one] || params[:many]

      # Dynamic Instance Method related_%{relation_name}
      define_method("#{prefix}_#{relation}") do
        params[:through] ? look_for(relation, params[:through]).flatten : send(relation)
      end
    end

    def somehow_has_options(key=nil)
      if const_defined?('SOMEHOW_HAS_RELATION')
        key ? const_get('SOMEHOW_HAS_RELATION')[key] : const_get('SOMEHOW_HAS_RELATION')
      end
    end
  end

  module InstanceMethods
    def look_for(relation, through)
      first_step = send(through)
      condition = self.class.somehow_has_options(:if)

      if first_step.is_a? Array
        first_step.map{|instance| instance.keep_looking_for(relation, condition)}
      else
        first_step.keep_looking_for(relation, condition)
      end
    end

    def keep_looking_for(relation, condition=nil)
      if self.class.somehow_has_options :through
        look_for(relation, self.class.somehow_has_options(:through))
      else
        condition.nil? ? send(relation) : send(relation).select{|instance| condition.to_proc.call(instance)}
      end
    end
  end
end

ActiveRecord::Base.send :include, SomehowHasRelation
