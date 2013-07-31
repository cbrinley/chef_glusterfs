actions :create, :delete
default_action :create

attribute :name, 
    :kind_of => String,
    :regex => /^(?![0-9]+$)(?!-)[a-zA-Z0-9-]{,63}(?<!-)$/,
    :name_attribute => true
