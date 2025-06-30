import { useEffect, useState } from "react";
import Table from "../components/table";
import { fetchData } from "../utils/api";
export default function Home() {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [data, setData] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData("users")
      .then(setData)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  return (
    <main>
      <h1>Users</h1>
      {loading ? <p>Loading...</p> : <Table data={data} />}
    </main>
  );
}
