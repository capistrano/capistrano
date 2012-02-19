#
# See https://github.com/jimweirich/rake/issues/81
#
if defined?(Rake::DeprecatedObjectDSL)
  Rake::DeprecatedObjectDSL.private_instance_methods.each do |m|
    Rake::DeprecatedObjectDSL.send("undef_method", m)
  end
end
