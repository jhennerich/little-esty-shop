class AdminController < ApplicationController
  def index
    @customers = Customer.top_five_customers
    @invoices = Invoice.pending_invoices
    @merchants = Merchant.top_5_merchants
    # Original GitHub API facade variable - keep for postarity  
    # @facade = GithubFacade.new
  end

end
