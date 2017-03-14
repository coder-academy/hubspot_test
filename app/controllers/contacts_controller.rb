class ContactsController < ApplicationController
  require 'json'
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  BASE_PATH                  = "https://api.hubapi.com"
  FORM_PATH                  = "https://forms.hubspot.com"
  API_KEY_PATH               = "?hapikey=bc32a775-2568-4875-96ea-b63fb9244af4"
  PORTAL_ID                  = "2106109"
  FORM_GUID                  = "3ad017fc-c84b-4d00-9bb0-a308a8452d80"

  CREATE_CONTACT_PATH        = "/contacts/v1/contact"
  GET_CONTACT_BY_EMAIL_PATH  = "/contacts/v1/contact/email/:contact_email/profile"
  GET_CONTACTS_BY_EMAIL_PATH = "/contacts/v1/contact/emails/batch"
  GET_CONTACT_BY_ID_PATH     = "/contacts/v1/contact/vid/:contact_id/profile"
  CONTACT_BATCH_PATH         = '/contacts/v1/contact/vids/batch'
  GET_CONTACT_BY_UTK_PATH    = "/contacts/v1/contact/utk/:contact_utk/profile"
  GET_CONTACTS_BY_UTK_PATH   = '/contacts/v1/contact/utks/batch'
  UPDATE_CONTACT_PATH        = "/contacts/v1/contact/vid/:contact_id/profile"
  DESTROY_CONTACT_PATH       = "/contacts/v1/contact/vid/:contact_id"
  CONTACTS_PATH              = "/contacts/v1/lists/all/contacts/all"
  RECENT_CONTACTS_PATH       = '/contacts/v1/lists/recently_updated/contacts/recent'
  SUBMIT_DATA_PATH           = '/uploads/form/v2/:portal_id/:form_guid'

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.all
  end

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if @contact.save
        # @contact.update_attribute(:vid, hubspotCreateContact(contact_params)["vid"].to_s)
        hubspotSubmitForm(contact_params)
        format.html { redirect_to @contact, notice: 'Contact was successfully created.' }
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        # hubspotUpdateContact(@contact.vid, contact_params)
        format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    # hubspotDeleteContact(@contact.vid)
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_contact
    @contact = Contact.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def contact_params
    params.require(:contact).permit(:firstname, :lastname, :email, :phone)
  end

  def hubspotGetContact(vid)
    url = "#{BASE_PATH}#{GET_CONTACT_BY_ID_PATH.gsub(/:contact_id/, vid)}/#{API_KEY_PATH}"
    @result = HTTParty.get(url)
    return @result
  end

  def hubspotCreateContact(params)
    url = "#{BASE_PATH}#{CREATE_CONTACT_PATH}#{API_KEY_PATH}"
    contact_hash = get_hash(params)
    @result = HTTParty.post(url, body: contact_hash.to_json, headers: { 'Content-Type' => 'application/json' }, format: :json)
    puts "HHHHHHHH"
    puts @result
    return @result
  end

  def hubspotUpdateContact(vid, params)
    url = "#{BASE_PATH}#{UPDATE_CONTACT_PATH.gsub(/:contact_id/, vid)}#{API_KEY_PATH}"
    contact_hash = get_hash(params)
    @result = HTTParty.post(url, body: contact_hash.to_json, headers: { 'Content-Type' => 'application/json' }, format: :json)
    return @result
  end

  def hubspotDeleteContact(vid)
    url = "#{BASE_PATH}#{DESTROY_CONTACT_PATH.gsub(/:contact_id/, vid)}#{API_KEY_PATH}"
    @result = HTTParty.delete(url)
    puts @result
    return @result
  end

  def hubspotSubmitForm(params)
    url = "#{FORM_PATH}#{SUBMIT_DATA_PATH.gsub(/:portal_id/, PORTAL_ID).gsub(/:form_guid/, FORM_GUID)}"
    submit_hash = form_hash({firstname: contact_params["firstname"], lastname: contact_params["lastname"], email: contact_params["email"]})
    @result = HTTParty.post(url, body: submit_hash, headers: {'Content-Type' => 'application/x-www-form-urlencoded'})
    puts @result
  end

  def form_hash(params)
    params["hs_context"] = {
      "hutk" => "#{cookies['hubspotutk']}",
      "ipAddress" => "#{request.remote_ip}",
      "pageUrl" => "#{request.original_url}",
      "pageName" => "Test"
    }
    return params.to_query
  end

  def get_hash(params)
    properties = []
    params.each do |key, data|
      hash = {"property" => key, "value" => data}
      properties << hash
    end
    return {"properties" => properties}
  end
end
