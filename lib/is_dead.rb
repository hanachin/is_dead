require "is_dead/version"

module IsDead
  class Error < StandardError; end

  module KernelPatch
    def require(feature)
      super
    end
  end
end

singleton_class.prepend(IsDead::KernelPatch)

require_tp = TracePoint.new(:call) do |tp|
  next unless tp.method_id == :require

  feature = tp.binding.local_variable_get(:feature)
  _ext, feature_path = RubyVM.resolve_feature_path(feature)
  $LOADED_FEATURES << feature_path
end
require_tp.enable(target: method(:require))
