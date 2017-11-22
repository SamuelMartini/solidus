module Spree
  module Admin
    class ZonesController < ResourceController
      before_action :load_data, except: :index

      def new
        @zone.zone_members.build
      end

      private

      def collection
        params[:q] ||= {}
        params[:q][:s] ||= "name asc"
        @search = super.ransack(params[:q])
        @zones = @search.result.page(params[:page]).per(params[:per_page])
      end

      def load_data
        require 'carmen'
        @countries = Carmen::Country.all.sort_by(&:name)
        @states = Carmen::Country.all.inject([]) do |all_states, country|
          all_states += country.subregions
        end.sort_by(&:name)
        @zones = Spree::Zone.order(:name)
      end
    end
  end
end
