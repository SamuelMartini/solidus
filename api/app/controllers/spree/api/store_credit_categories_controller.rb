module Spree
  module Api
    class StoreCreditCategoriesController < Spree::Api::BaseController
      def update
        @credit_category = Spree::StoreCreditCategory.accessible_by(current_ability, :update).find(params[:id])
        @credit_category.update_attributes(credit_params)
        respond_with(@credit_category)
      end

      def destroy
        @credit_category = Spree::StoreCreditCategory.accessible_by(current_ability, :destroy).find(params[:id])
        @credit_category.destroy
        respond_with(@credit_category, status: 204)
      end

      private

      def credit_params
        params.require(:store_credit_category).permit(:name)
      end
    end
  end
end
