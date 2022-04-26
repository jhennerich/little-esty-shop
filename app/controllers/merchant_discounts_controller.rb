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

  def destroy
    BulkDiscount.destroy(params[:id])
    redirect_to "/merchants/#{params[:merchant_id]}/bulk_discounts/"
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
  end

  def update
    discount = BulkDiscount.find(params[:id])
    if discount.update(discount_params)
      redirect_to "/merchants/#{params[:merchant_id]}/bulk_discounts/#{params[:id]}/"
    else
      flash[:notice] = "Discount not updated: at least one missing field required"
      redirect_to "/merchants/#{params[:merchant_id]}/bulk_discounts/#{params[:id]}/edit/"
    end
  end

  private

  def discount_params
    params.permit(:threshold, :discount)
  end
end
