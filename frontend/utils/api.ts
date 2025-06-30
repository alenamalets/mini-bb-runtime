const API_BASE = process.env.NEXT_PUBLIC_API_BASE;

export async function fetchSchema(table: string) {
  const res = await fetch(`${API_BASE}/schema/${table}`);
  if (!res.ok) throw new Error("Failed to fetch schema");
  return res.json();
}

export async function fetchData(table: string) {
  const res = await fetch(`${API_BASE}/data/${table}`);
  if (!res.ok) throw new Error("Failed to fetch data");
  return res.json();
}
