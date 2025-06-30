import { useEffect, useState } from "react";
import Table from "../components/table";
import { fetchData, fetchSchema } from "../utils/api";
import CreateRecordModal from "../components/create-record-modal";

export default function Home() {
  const [columns, setColumns] = useState<string[]>([]);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [data, setData] = useState<any[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);

  const [filterText, setFilterText] = useState("");
  const [sortBy, setSortBy] = useState<string | null>(null);
  const [sortAsc, setSortAsc] = useState(true);
  const [page, setPage] = useState(1); // page starts at 1
  const pageSize = 5;
  const totalPages = Math.ceil(totalCount / pageSize);

  useEffect(() => {
    setLoading(true);
    Promise.all([
      fetchSchema("users"),
      fetchData("users", {
        filter: filterText
          ? { name: filterText, email: filterText }
          : undefined,
        sort: sortBy || undefined,
        limit: pageSize,
        page,
      }),
    ])
      .then(([schema, result]) => {
        setColumns(schema.columns);
        setData(result.rows);
        setTotalCount(result.total_count);
      })
      .finally(() => setLoading(false));
  }, [filterText, sortBy, page]);

  return (
    <main className="min-h-screen bg-gray-100 py-10 px-4 sm:px-8">
      <div className="max-w-4xl mx-auto bg-white rounded-xl shadow-md p-6">
        {/* 🧾 Header: title + add button */}
        <div className="flex justify-between items-center mb-4">
          <h1 className="text-2xl font-bold text-gray-800">Users</h1>
          <button
            onClick={() => setShowModal(true)}
            className="border border-gray-800 text-gray-800 hover:bg-gray-100 px-4 py-2 rounded shadow-sm"
          >
            + Add Record
          </button>
        </div>

        {/* 🔍 Filter input */}
        <div className="mb-4">
          <input
            value={filterText}
            onChange={(e) => {
              setFilterText(e.target.value);
              setPage(1);
            }}
            placeholder="Filter by name or email..."
            className="w-full sm:w-1/2 border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring focus:ring-blue-200"
          />
        </div>

        {/* ⏳ Loading state OR table + pagination */}
        {loading ? (
          <div className="space-y-2 w-full sm:w-1/2">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="h-4 bg-gray-200 rounded animate-pulse" />
            ))}
          </div>
        ) : (
          <>
            <div className="overflow-x-auto">
              <Table
                data={data}
                columns={columns}
                sortBy={sortBy}
                sortAsc={sortAsc}
                onSort={(col) => {
                  if (sortBy !== col) {
                    setSortBy(col);
                    setSortAsc(true);
                  } else if (sortAsc) {
                    setSortAsc(false);
                  } else {
                    setSortBy(null);
                    setSortAsc(true);
                  }
                  setPage(1);
                }}
              />
            </div>

            {/* ⏩ Pagination */}
            <div className="mt-4 flex justify-center items-center gap-4">
              <button
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={page === 1}
                className="px-3 py-1 rounded border bg-white disabled:opacity-50 hover:bg-gray-50"
              >
                Prev
              </button>
              <span className="text-gray-700">
                Page {page} of {totalPages}
              </span>
              <button
                onClick={() => setPage((p) => p + 1)}
                disabled={page >= totalPages}
                className="px-3 py-1 rounded border bg-white disabled:opacity-50 hover:bg-gray-50"
              >
                Next
              </button>
            </div>
          </>
        )}

        {/* 🧩 Modal */}
        <CreateRecordModal
          isOpen={showModal}
          onClose={() => setShowModal(false)}
          onSuccess={() => {
            fetchData("users", {
              filter: filterText
                ? { name: filterText, email: filterText }
                : undefined,
              sort: sortBy || undefined,
              limit: pageSize,
              page,
            }).then((result) => {
              setData(result.rows);
              setTotalCount(result.total_count);
            });
          }}
        />
      </div>
    </main>
  );
}
