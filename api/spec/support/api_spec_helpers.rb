module ApiSpecHelpers
  def parse_json(json_body)
    JSON.parse(json_body)
  end
end