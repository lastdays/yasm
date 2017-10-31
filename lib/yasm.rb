require "yasm/version"
require 'yasm/transition'
require 'yasm/transitions'
require 'yasm/event'
require 'pry'

module Yasm
  TransitionNotPermitted = Class.new(StandardError)

  def self.included(target)
    target.extend(self::ClassMethods)
    target.prepend(self::PrependMethods)
  end

  def state
    @__state__
  end

  def state=(new_state)
    @__state__ = new_state
  end

  module PrependMethods
    def initialize
      super
      @__state__ = self.class.__initial__
    end
  end

  module ClassMethods
    attr_accessor :__states__, :__events__, :__transitions__, :__initial__

    def state_machine
      yield if block_given?
    end

    def state(*names, **options)
      (@__states__ ||= []).push(*names)
      initial = options.fetch(:initial, false)
      @__initial__ = names.first if initial

      names.each do |name|
        define_method("#{name}?") { state == name }
      end
    end

    def event(name)
      event = Yasm::Event.new(name)
      (@__events__ ||= []).push(event)
      @__current_event__ = event
      yield if block_given?
      @__current_event__ = nil

      define_method("#{name}") do
        tr = event.transitions
          .select { |t| t.from.include?(@__state__) }

        self.state = tr.first.to if tr && tr.first
      end

      define_method("#{name}!") do
        tr = event.transitions
          .select { |t| t.from.include?(@__state__) }

        if tr && tr.first
          self.state = tr.first.to
        else
          raise Yasm::TransitionNotPermitted
        end
      end
    end

    def transition(params)
      params[:from] = [params[:from]].flatten
      @__current_event__.transitions.push(Yasm::Transition.new(from: params[:from], to: params[:to]))
    end
  end
end
