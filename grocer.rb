require "pry"

def consolidate_cart(cart)
  consolidated_cart_hash = {}
  cart.each do |item|
      count = cart.count(item)
    item.each do |name,details|
      new_details_hash = details.merge({:count=>count})
      new_item = {name => new_details_hash}
      consolidated_cart_hash = new_item.merge!(consolidated_cart_hash)
    end
  end
  cart = consolidated_cart_hash
  return cart#consolidated_cart_hash
end # consolidate_cart method end


def apply_coupons(cart,coupons)
  coupon_item_names = []
  coupons.each do |coupon|
      coupon_item_names << coupon[:item]
  end
  # make array of coupon items to check if a coupon exists for item. if not, add item to updated_cart hash.
  updated_cart = {}
  final_couponed_cart = {}
  total_applied_coupon_count = 0
  i = 0
  while i < cart.length
    cart.each do |item_name,item_details|
      couponed_cart = {}
      applied_current_coupon_count = 0
      if coupon_item_names.include?(item_name)
        # coupon exists that can be applied
        coupons.each_with_index do |coupon,index|
          # set applied_coupon_count to be used to figure out non_couponed_item count
          # find valid coupon
          if item_name == coupon[:item] && item_details[:count] >= coupon[:num]
            # coupon and item match; apply coupon
            #if item_details[:count] >= coupon[:num]
              # if cart item count is greater than num needed for coupon; apply coupon, edit orig item count
              applied_current_coupon_count += 1

              # apply coupon and create couponed item hash
              couponed_item_details = {:price => coupon[:cost], :clearance => item_details[:clearance], :count => applied_current_coupon_count}
              couponed_item = {"#{item_name} W/COUPON" => couponed_item_details}
              couponed_cart = couponed_cart.merge!(couponed_item)
#binding.pry
              # edit orig item with new count
              non_couponed_item_count = (item_details[:count] -  coupon[:num])

              non_couponed_item_count_hash = {:count => non_couponed_item_count}

              new_non_couponed_item_details = item_details.merge!(non_couponed_item_count_hash)
          end
        end
        final_couponed_cart = final_couponed_cart.merge!(couponed_cart)
      end
    end # end of cart iteration
    cart.merge!(final_couponed_cart)
    i +=1
  end #end while loop
  return cart
end #apply_coupons method end


def apply_clearance(cart)

  cart.each do |item_name,item_details|
    if item_details[:clearance] == true

      clearanced_item_price = item_details[:price] - ((item_details[:price] * (0.20)))

      clearanced_item_price_hash = {:price => clearanced_item_price}

      item_details = item_details.merge!(clearanced_item_price_hash)

    end
  end

end # apply_clearance method end

def checkout(cart, coupons)

  cart = consolidate_cart(cart)

  cart = apply_coupons(cart, coupons)

  cart = apply_clearance(cart)

  cart_total = 0

  cart.each do |item,item_details|
    item_price = item_details[:price] * item_details[:count]
    cart_total += item_price
  end

  if cart_total > 100
    cart_discount = cart_total * (0.10)
    cart_total = cart_total - cart_discount
  end
  return cart_total

end

