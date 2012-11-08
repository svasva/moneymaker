module ApplicationHelper
  def resource_attrs(resource)
    hash = {}
    resource.fields.each do |name, meta|
      next if name =~ /_id/ or name =~ /^_/
      hash[name.to_sym] = resource[name.to_sym]
    end
    return hash
  end

  def collection_fields(collection)
    arr = []
    collection.fields.each do |name, data|
      arr << name unless name =~ /_id/ or name =~ /^_/
    end
    return arr
  end
end
