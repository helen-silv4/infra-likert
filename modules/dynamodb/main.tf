resource "aws_dynamodb_table" "tb_usuarios" {
  name         = "tb_usuarios"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id_usuario"

  attribute {
    name = "id_usuario"
    type = "S"
  }
}

resource "aws_dynamodb_table" "tb_avaliacoes" {
    name = "tb_avaliacoes"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "id_avaliacao"

    attribute {
      name = "id_avaliacao"
      type = "S"
    }
}