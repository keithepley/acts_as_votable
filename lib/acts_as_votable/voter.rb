module ActsAsVotable
  module Voter

    def self.included(base)

      # allow user to define these
      aliases = {
        :vote_up_for   => [:likes, :upvotes, :up_votes],
        :vote_down_for => [:dislikes, :downvotes, :down_votes],
        :unvote_for    => [:unlike, :undislike]
      }

      base.class_eval do

        has_many :votes, :class_name => "ActsAsVotable::Vote", :as => :voter do
          def votables
            includes(:votable).map(&:votable)
          end
        end

        aliases.each do |method, links|
          links.each do |new_method|
            alias_method(new_method, method)
          end
        end

      end

    end

    # voting
    def vote args
      args[:votable].vote args.merge({:voter => self})
    end

    def vote_up_for model=nil
      vote :votable => model, :vote => true
    end

    def vote_down_for model
      vote :votable => model, :vote => false
    end

    def unvote_for model
      model.unvote :voter => self
    end

    # results
    def voted_on? votable
      votes = find_votes(:votable_id => votable.id, :votable_type => votable.class.name)
      votes.size > 0
    end
    alias :voted_for? :voted_on?

    def voted_up_on? votable
      votes = find_votes(:votable_id => votable.id, :votable_type => votable.class.name, :vote_flag => true)
      votes.size > 0
    end
    alias :voted_up_for? :voted_up_on?

    def voted_down_on? votable
      votes = find_votes(:votable_id => votable.id, :votable_type => votable.class.name, :vote_flag => false)
      votes.size > 0
    end
    alias :voted_down_for? :voted_down_on?

    def voted_as_when_voting_on votable
      votes = find_votes(:votable_id => votable.id, :votable_type => votable.class.name)
      return nil if votes.size == 0
      return votes.first.vote_flag
    end
    alias :voted_as_when_voted_for :voted_as_when_voting_on

    def find_votes extra_conditions = {}
      votes.where(extra_conditions)
    end

    def find_up_votes
      find_votes :vote_flag => true
    end

    def find_down_votes
      find_votes :vote_flag => false
    end

    def find_votes_for_class klass, extra_conditions = {}
      find_votes extra_conditions.merge({:votable_type => klass.name})
    end

    def find_up_votes_for_class klass
      find_votes_for_class klass, :vote_flag => true
    end

    def find_down_votes_for_class klass
      find_votes_for_class klass, :vote_flag => false
    end

    # Including polymporphic relations for eager loading
    def include_objects
      ActsAsVotable::Vote.includes(:votable)
    end

    def find_voted_items extra_conditions = {}
      options = extra_conditions.merge :voter_id => id, :voter_type => self.class.name
      include_objects.where(options).collect(&:votable)
    end

    def find_up_voted_items extra_conditions = {}
      find_voted_items extra_conditions.merge(:vote_flag => true)
    end
    alias_method :find_liked_items, :find_up_voted_items

    def find_down_voted_items extra_conditions = {}
      find_voted_items extra_conditions.merge(:vote_flag => false)
    end
    alias_method :find_disliked_items, :find_down_voted_items

    def get_voted klass, extra_conditions = {}
      klass.joins(:votes).merge find_votes(extra_conditions)
    end

    def get_up_voted klass
      klass.joins(:votes).merge find_up_votes
    end

    def get_down_voted klass
      klass.joins(:votes).merge find_down_votes
    end
  end
end
