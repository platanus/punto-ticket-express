module QrcodeHelper
	require 'rqrcode'

	def render_qr_code text, size = 3
		qr = RQRCode::QRCode.new(text)
		sizeStyle = "width: #{size}px; height: #{size}px;"

		haml_tag :table, class: "qrcode pull-right" do
			qr.modules.each_index do |x|
				haml_tag :tr
				qr.modules.each_index do |y|
					if qr.dark? x, y
						haml_tag :td, class: "black", style: sizeStyle
					else
						haml_tag :td, class: "white", style: sizeStyle
					end
				end
			end
		end
	end
end