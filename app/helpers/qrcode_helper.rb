module QrcodeHelper
	require 'rqrcode'

	def render_qr_code text, size = 3
		qr = RQRCode::QRCode.new(text)
		sizeStyle = "width: #{size}px; height: #{size}px;"

		content_tag :table, class: "qrcode pull-right" do
			qr.modules.each_index do |x|
				concat(content_tag(:tr) do
					qr.modules.each_index do |y|
						if qr.dark? x, y
							concat content_tag(:td, nil, class: "black", style: sizeStyle)
						else
							concat content_tag(:td, nil, class: "white", style: sizeStyle)
						end
					end
				end)
			end
		end
	end
end