$things = {}

def alert_hit(object_id)
  $things.each do |k,v|
    unless v[1]
      if v[0].object_id == object_id
        v[1] = true
        # puts "#{k} hit a bad method"
      end
    end
  end
end

def alert_others_hit(things)
  $things.each do |k,v|
    unless v[1]
      if Array.wrap(things).map(&:object_id).include?(v[0].object_id)
        v[1] = true
      end
    end
  end
end

module Instrument
  def association(*attrs)
    # if we are keeping track of one of these things, they need to hit the db
    # and thus can't be stubbed
    alert_hit(self.object_id)
    things_hit = super
    alert_others_hit(things_hit.target)
    things_hit
  end

  def id(*attrs)
    alert_hit(self.object_id)
    super
  end

  def connection(*attrs)
    alert_hit(self.object_id)
    super
  end

  def decrement!(*attrs)
    alert_hit(self.object_id)
    super
  end

  def decrement(*attrs)
    alert_hit(self.object_id)
    super
  end

  def delete(*attrs)
    alert_hit(self.object_id)
    super
  end

  def destroy!(*attrs)
    alert_hit(self.object_id)
    super
  end

  def destroy(*attrs)
    alert_hit(self.object_id)
    super
  end

  def increment!(*attrs)
    alert_hit(self.object_id)
    super
  end

  def increment(*attrs)
    alert_hit(self.object_id)
    super
  end

  def reload(*attrs)
    alert_hit(self.object_id)
    super
  end

  def save!(*attrs)
    alert_hit(self.object_id)
    super
  end

  def save(*attrs)
    alert_hit(self.object_id)
    super
  end

  def toggle!(*attrs)
    alert_hit(self.object_id)
    super
  end

  def toggle(*attrs)
    alert_hit(self.object_id)
    super
  end

  def touch(*attrs)
    alert_hit(self.object_id)
    super
  end

  def update!(*attrs)
    alert_hit(self.object_id)
    super
  end

  def update(*attrs)
    alert_hit(self.object_id)
    super
  end

  def update_attribute(*attrs)
    alert_hit(self.object_id)
    super
  end

  def update_attributes!(*attrs)
    alert_hit(self.object_id)
    super
  end

  def update_attributes(*attrs)
    alert_hit(self.object_id)
    super
  end

  def update_column(*attrs)
    alert_hit(self.object_id)
    super
  end

  def update_columns(*attrs)
    alert_hit(self.object_id)
    super
  end
end
require 'factory_bot'

FactoryBot::Strategy::Create.class_eval do
  def result(evaluation)
    evaluation.object.tap do |instance|
      evaluation.notify(:after_build, instance)
      evaluation.notify(:before_create, instance)
      evaluation.create(instance)
      evaluation.notify(:after_create, instance)
      instance.singleton_class.prepend Instrument
      unless $things.values.map(&:first).include?(instance)
        $things[instance.to_s] = [instance, false]
      end
    end
  end
end

# Go sit in front of every AR method
module Spree
  module BuildStubbedCandidate
    def self.watch_this(name, variable)
      # puts "Added #{variable} to watch list"
      variable.singleton_class.prepend Instrument
      $things[name] = [variable, false]
    end
  end
end
