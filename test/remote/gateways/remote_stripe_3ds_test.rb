require 'test_helper'

class RemoteStripe3DSTest < Test::Unit::TestCase
  CHARGE_ID_REGEX = /ch_[a-zA-Z\d]{24}/

  def setup
    @gateway = StripeGateway.new(fixtures(:stripe))
    @amount = 100

    @options = {
      :currency => 'USD',
      :description => 'ActiveMerchant Test Purchase',
      :email => 'wow@example.com',
      :execute_threed => true, 
      :callback_url => 'http://www.example.com/callback'
    }
    @credit_card = credit_card('4000000000003063')
    @non_3ds_credit_card = credit_card('378282246310005')
  end

  def test_successful_purchase_with_3ds
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response
    assert_equal 'source', response.params['object']
    assert_equal 'chargeable', response.params['status']
    assert_equal 'three_d_secure', response.params['type']
    assert_equal false, response.params['three_d_secure']['authenticated']
  end

  def test_successful_authorize_with_3ds
    assert response = @gateway.authorize(@amount, @credit_card, @options)
    assert_success response
    assert_equal 'source', response.params['object']
    assert_equal 'chargeable', response.params['status']
    assert_equal 'three_d_secure', response.params['type']
    assert_equal false, response.params['three_d_secure']['authenticated']
  end

  def test_successful_purchase_with_non3ds
    assert response = @gateway.purchase(@amount, @non_3ds_credit_card, @options)
    assert_success response
    assert_equal 'charge', response.params['object']
    assert_equal true, response.params['captured']
  end

  def test_successful_authorize_with_non3ds
    assert response = @gateway.authorize(@amount, @non_3ds_credit_card, @options)
    assert_success response
    assert_equal 'charge', response.params['object']
    assert_equal false, response.params['captured']
  end
end
