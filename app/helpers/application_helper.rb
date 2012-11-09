module ApplicationHelper
  def resource_attrs(resource, timestamps = false)
    hash = {}
    resource.fields.each do |name, meta|
      next if not timestamps and name == 'created_at' or name == 'updated_at'
      next if name =~ /^_id/ or name =~ /^_/
      hash[name.to_sym] = resource[name.to_sym]
    end
    return hash
  end

  def collection_fields(collection, timestamps = false)
    arr = []
    collection.fields.each do |name, data|
      next if not timestamps and name == 'created_at' or name == 'updated_at'
      arr << name unless name =~ /^_id/ or name =~ /^_/
    end
    return arr
  end
end
