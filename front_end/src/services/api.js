const BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:9000'

async function request(path, options = {}) {
  const response = await fetch(`${BASE_URL}${path}`, {
    ...options,
    headers: { 'Content-Type': 'application/json; charset=utf-8', ...options.headers },
  })

  const rawBody = await response.text()
  let body = rawBody
  try {
    body = rawBody ? JSON.parse(rawBody) : null
  } catch {
    // resposta não é JSON, mantém como texto
  }

  if (!response.ok) {
    throw new Error(typeof body === 'string' ? body : body?.message ?? 'Erro na requisição')
  }

  return body
}

export function loginUser(email, password) {
  return request('/users/login', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  })
}

export function registerUser({ firstName, lastName, email, password }) {
  return request('/users/cadastro', {
    method: 'POST',
    body: JSON.stringify({
      first_name: firstName,
      last_name: lastName,
      email,
      password,
    }),
  })
}

export function updateUser({ currentEmail, currentPassword, firstName, lastName, email, password }) {
  return request('/users/atualizar', {
    method: 'PUT',
    body: JSON.stringify({
      email_where: currentEmail,
      password_where: currentPassword,
      first_name: firstName,
      last_name: lastName,
      email,
      password,
    }),
  })
}

export function deleteUser(email, password) {
  return request('/users/deletar', {
    method: 'DELETE',
    body: JSON.stringify({ email, password }),
  })
}
