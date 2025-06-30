import { useEffect, useState } from "react";
import Table from "../components/table";
import { fetchData, fetchSchema } from "../utils/api";

export default function Home() {
  const [columns, setColumns] = useState<string[]>([]);
  const [data, setData] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([fetchSchema("users"), fetchData("users")])
      .then(([schema, records]) => {
        setColumns(schema.columns);
        setData(records);
      })
      .finally(() => setLoading(false));
  }, []);

  return (
    <main className="min-h-screen bg-gray-50 px-6 py-10">
      <h1 className="mb-6 text-3xl font-bold text-gray-800">Users</h1>
      {loading ? (
        <div className="space-y-2 w-full sm:w-1/2">
          {[...Array(5)].map((_, i) => (
            <div key={i} className="h-4 bg-gray-200 rounded animate-pulse" />
          ))}
        </div>
      ) : (
        <div className="flex justify-center">
          <Table data={data} columns={columns} />
        </div>
      )}
    </main>
  );
}
