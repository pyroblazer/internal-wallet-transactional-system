class WalletSerializer < ActiveModel::Serializer
  attributes :id, :walletable_type, :walletable_id, :balance

  private
  def balance
    object.balance.to_f
  end
end
