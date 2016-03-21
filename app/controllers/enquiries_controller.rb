class EnquiriesController < ApplicationController
  before_action :set_enquiry, only: [:show, :edit, :update, :destroy]

  # GET /enquiries
  # GET /enquiries.json
  def index
    # Hubspot::Contact.create!("aaron@coderfactory.com", {firstname: "Test", lastname: "Contact"})
    lists = HTTParty.get "https://api.hubapi.com/contacts/v1/lists?hapikey=dec3140b-502f-42da-ada2-6c3c19772d94"
    puts "HHHHHHHHHHH"
    listp = lists.first.last.select { |list| list["name"] == "New Test List"}
    listp = listp.first
    puts listp["name"]
    puts "FFFFFFFFFFFFFFF"
    contact_list = HTTParty.get "https://api.hubapi.com/contacts/v1/lists/#{listp['listId'].to_i}/contacts/all?hapikey=dec3140b-502f-42da-ada2-6c3c19772d94"
    puts contact_list["contacts"].first["properties"]["firstname"]["value"]
    puts "LLLLLLLLLLLLLL"
    puts listp
    @enquiries = Enquiry.all
  end

  # GET /enquiries/1
  # GET /enquiries/1.json
  def show
  end

  # GET /enquiries/new
  def new
    @enquiry = Enquiry.new
  end

  # GET /enquiries/1/edit
  def edit
  end

  # POST /enquiries
  # POST /enquiries.json
  def create
    @enquiry = Enquiry.new(enquiry_params)

    respond_to do |format|
      if @enquiry.save
        format.html { redirect_to @enquiry, notice: 'Enquiry was successfully created.' }
        format.json { render :show, status: :created, location: @enquiry }
      else
        format.html { render :new }
        format.json { render json: @enquiry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /enquiries/1
  # PATCH/PUT /enquiries/1.json
  def update
    respond_to do |format|
      if @enquiry.update(enquiry_params)
        format.html { redirect_to @enquiry, notice: 'Enquiry was successfully updated.' }
        format.json { render :show, status: :ok, location: @enquiry }
      else
        format.html { render :edit }
        format.json { render json: @enquiry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /enquiries/1
  # DELETE /enquiries/1.json
  def destroy
    @enquiry.destroy
    respond_to do |format|
      format.html { redirect_to enquiries_url, notice: 'Enquiry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_enquiry
      @enquiry = Enquiry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def enquiry_params
      params.require(:enquiry).permit(:first_name, :last_name, :email, :phone)
    end
end
