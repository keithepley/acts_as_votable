require 'acts_as_votable/helpers/words'

module ActsAsVotable
  class Vote < ::ActiveRecord::Base

    include Helpers::Words

    if Rails.version.to_i < 4
      attr_accessible :votable_id, :votable_type,
        :voter_id, :voter_type,
        :votable, :voter,
        :vote_flag
    end

    belongs_to :votable, :polymorphic => true, :touch => true
    belongs_to :voter, :polymorphic => true, :touch => true

    scope :up, -> { where vote_flag: true }
    scope :down, -> { where vote_flag: false }
    scope :for_type, lambda{ |klass| where(:votable_type => klass) }
    scope :by_type,  lambda{ |klass| where(:voter_type => klass) }

    validates_presence_of :votable_id
    validates_presence_of :voter_id

  end

end

