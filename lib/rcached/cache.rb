class RCached::Cache

  attr_reader :storage

  def initialize
    @storage = {}
  end

  # Run memcached compatible command with supplied *args
  def run(command, *args)
    send(command, *args)
  end

  # "set" means "store this data".
  def set(key, flags, expiration, length, data)
    storage[key] = {
      expiration: expiration,
      flags: flags,
      value: data
    }

    'STORED'
  end

  # "add" means "store this data, but only if the server *doesn't* already
  # hold data for this key".
  def add(key, flags, expiration, length, data)
    if !storage.keys? key
      set(key, flags, expiration, data)
    elsif
      'NOT_STORED'
    end
  end

  # "replace" means "store this data, but only if the server *does*
  # already hold data for this key".
  def replace(key, flags, expiration, length, data)
    if storage.keys? key
      set(key, flags, expiration, data)
    elsif
      'NOT_STORED'
    end
  end

  # "append" means "add this data to an existing key after existing data".
  def append(key, length, data)
  end

  # "prepend" means "add this data to an existing key before existing data".
  def prepend(key, length, data)
  end

  # "cas" is a check and set operation which means "store this data but
  # only if no one else has updated since I last fetched it."
  def cas(key, flags, expiration, length, casunique, data)
  end

  def get(keys)
    values = ""

    keys.each do |k|
      entry = storage[k]
      values << "#{entry[:value]} #{k} #{entry[:flags]} #{entry[:value].length}\r\n"
    end

    values
  end

  def gets(keys)
  end

end
