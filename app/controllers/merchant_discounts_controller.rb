class MerchantDiscountsController < ApplicationController

  def index
    @merchant = Merchant.find(params[:merchant_id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    merchant.bulk_discounts.create!(discount_params)
    redirect_to "/merchants/#{params[:merchant_id]}/bulk_discounts/"
  end

  private

  def discount_params
    params.permit(:threshold, :discount)
  end
end
