const API_BASE = process.env.NEXT_PUBLIC_API_BASE;

export async function fetchSchema(table: string) {
  const res = await fetch(`${API_BASE}/schema/${table}`);
  if (!res.ok) throw new Error("Failed to fetch schema");
  return res.json();
}

export async function fetchData(
  table: string,
  options?: {
    filter?: Record<string, string>;
    sort?: string;
    order?: "asc" | "desc";
    limit?: number;
    page?: number;
  }
) {
  const query = new URLSearchParams();

  if (options?.filter) {
    Object.entries(options.filter).forEach(([k, v]) =>
      query.append(`filter[${k}]`, v)
    );
  }

  if (options?.sort) query.append("sort", options.sort);
  if (options?.order) query.append("order", options.order);
  if (options?.limit) query.append("limit", String(options.limit));
  if (options?.page) query.append("page", String(options.page));

  const res = await fetch(`${API_BASE}/data/${table}?${query.toString()}`);

  if (!res.ok) {
    throw new Error("Failed to fetch data");
  }
  return res.json();
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function createRecord(table: string, data: Record<string, any>) {
  const res = await fetch(`${API_BASE}/data/${table}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(data),
  });

  if (!res.ok) {
    throw new Error("Failed to create record");
  }

  return res.json();
}
