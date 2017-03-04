class BotAction < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :user
  validates_presence_of :user_input, message: "can't be empty"
  validates_length_of :user_input, minimum: 2, maximum: 200, message: "accepts only 2 - 200 characters"
  before_save :strip_user_input

  TRAINING_DATA = YAML.load_file('config/chatbot/training.yml')
  #puts "\n\nTRAINING DATA = #{TRAINING_DATA.inspect}\n\n"
  ARRAY_SINGULAR = ["laptop", "phone", "mobile", "television", "tv", "home"]  #singular words related to our models
  ARRAY_PLURAL = ARRAY_SINGULAR.map {|v| v.pluralize}                 #pluralized words of above array
  FINAL_ARRAY = ARRAY_SINGULAR + ARRAY_PLURAL                         #array with both singular and plural words
  # puts "\n\n\nFINAL_ARRAY #{FINAL_ARRAY.inspect}\n\n\n"

  def process_input user_input
    user_input_tokens = clean_user_input(user_input)
    common_array = user_input_tokens & FINAL_ARRAY  #Intersection of both arrays
    common_word = common_array.present? ? common_array.first.singularize : "classification_failed"
    #puts "\n\nCommon Word = #{common_word.inspect}\n\n"
    send("#{common_word}_enquiry", user_input_tokens)
  end

  def classification_failed_enquiry(*args)
    self.update_attribute(:bot_response, error_response)
    return false
  end

  def nbayes_classification(user_input_tokens, method_name)
    nbayes = NBayes::Base.new(binarized: true)
    
    TRAINING_DATA[method_name.to_s].each do |key, value|   #getting the inner hash, ex: 'new_laptop_enquiry' hash
      category = key                                       #assigning key as category (class), ex: 'new_laptop_enquiry'
      #puts "\n\nCategory: #{category.inspect}\n\n"
      value.each do |str|
        #puts "\n\nString: #{str.inspect}\n\n"
        nbayes.train(str.split(/\s+/), category)           #Training the nbayes object, with each string under 'new_laptop_enquiry' class
      end
    end

    nbayes.assume_uniform = true                           #

    result = nbayes.classify(user_input_tokens)            #classifying the input form user 
    #nbayes.dump('config/rembot/dump.yml')                 #dump of trained data, for us to observe how the classification is done

    result.each do |k, v|
      puts "\n#{(v * 100)} => #{k}\n"                      #display of classified log probabilities for each category
    end

    result.max_class                                       #final classified category, ex: 'new_laptop_enquiry'
  end

  #classifications related to laptops
  def laptop_enquiry(user_input_tokens)
    send(nbayes_classification(user_input_tokens, __method__))
  end
 
  def new_laptop_enquiry(*args)
    self.update_attribute(:bot_response, "Redirected to new laptop page")
    new_polymorphic_path('laptop')
  end
 
  def laptop_index_enquiry(*args)
    self.update_attribute(:bot_response, "Redirected to laptops index page")
    polymorphic_path('laptops')
  end
 
  def laptop_count_enquiry(*args)
    laptop_count = Laptop.all.count
    self.update_attribute(:bot_response, "There are #{laptop_count} laptops in total")
    return false
  end
  
  #classifications related to phones
  def mobile_enquiry(user_input_tokens)
    phone_enquiry(user_input_tokens)
  end

  def phone_enquiry(user_input_tokens)
    send(nbayes_classification(user_input_tokens, __method__))
  end
 
  def new_phone_enquiry(*args)
    self.update_attribute(:bot_response, "Redirected to new phone page")
    new_polymorphic_path('phone')
  end
 
  def phone_index_enquiry(*args)
    self.update_attribute(:bot_response, "Redirected to phones index page")
    polymorphic_path('phones')
  end

  def phone_count_enquiry(*args)
    phone_count = Phone.all.count
    self.update_attribute(:bot_response, "There are #{phone_count} phones in total")
    return false
  end
 
  #classifications related to televisions
  def tv_enquiry(user_input_tokens)
    television_enquiry(user_input_tokens)
  end

  def television_enquiry(user_input_tokens)
    send(nbayes_classification(user_input_tokens, __method__))
  end
 
  def new_television_enquiry(*args)
    self.update_attribute(:bot_response, "Redirected to new television page")
    new_polymorphic_path('television')
  end
 
  def television_index_enquiry(*args)
    self.update_attribute(:bot_response, "Redirected to televisions index page")
    polymorphic_path('televisions')
  end

  def television_count_enquiry(*args)
    television_count = Television.all.count
    self.update_attribute(:bot_response, "There are #{television_count} televisions in total")
    return false
  end
 
  #classification related to home page
  def home_enquiry(*args)
    self.update_attribute(:bot_response, "Redirected you to home page")
    polymorphic_path("root")
  end

  private

  #Random error message from array
  def error_response
    ["I'm Sorry, I don't understand. Please try again",
     "Oh oh! Something went wrong. Please try again", 
     "Um... Sorry, I don't understand. Did you input correct words?"].sample
  end

  def strip_user_input
    self.user_input = self.user_input.squish
  end

  def clean_user_input(user_input)
    rm_spl_chars = user_input.downcase.gsub(/[^a-zA-Z0-9-#\s]/, '')
    rm_spl_chars.split(/\s+/)
  end
end
