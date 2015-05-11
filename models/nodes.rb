class Node < ActiveRecord::Base
  has_many :events, dependent: :destroy
  has_many :sensu_events, dependent: :destroy
  has_many :sensu_stashes, dependent: :destroy
  has_many :sensu_checks, dependent: :destroy
end
class Event < ActiveRecord::Base
  belongs_to :node, :counter_cache => true
end
class SensuEvent < ActiveRecord::Base
  belongs_to :node, :counter_cache => true
end
class SensuStash < ActiveRecord::Base
  belongs_to :node, :counter_cache => true
end
class SensuCheck < ActiveRecord::Base
  belongs_to :node, :counter_cache => true
end
