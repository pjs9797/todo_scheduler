import React, { useEffect, useMemo, useState } from "react";
import {
  DndContext,
  PointerSensor,
  closestCenter,
  useSensor,
  useSensors,
} from "@dnd-kit/core";
import {
  arrayMove,
  SortableContext,
  useSortable,
  verticalListSortingStrategy,
} from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";
import {
  Plus,
  GripVertical,
  Pencil,
  Trash2,
  Folder,
  Check,
  X,
  Settings,
} from "lucide-react";

/**
 * Interactive prototype (web) for:
 * - Tasks (title + minutes) + Categories
 * - Filter by category
 * - Reorder categories & tasks by drag
 * - Pick end time -> calculate required start time
 * - Local persistence via localStorage (as a "local DB" prototype)
 */

// --------------------
// Utils
// --------------------
const uid = () =>
  (typeof crypto !== "undefined" && crypto.randomUUID
    ? crypto.randomUUID()
    : `id_${Math.random().toString(16).slice(2)}_${Date.now()}`);

function clampInt(n, min, max) {
  const x = Number.isFinite(n) ? Math.floor(n) : NaN;
  if (!Number.isFinite(x)) return null;
  return Math.min(max, Math.max(min, x));
}

function hexToRgba(hex, a = 0.12) {
  if (!hex || typeof hex !== "string") return `rgba(0,0,0,${a})`;
  const h = hex.replace("#", "");
  const full = h.length === 3 ? h.split("").map((c) => c + c).join("") : h;
  if (full.length !== 6) return `rgba(0,0,0,${a})`;
  const r = parseInt(full.slice(0, 2), 16);
  const g = parseInt(full.slice(2, 4), 16);
  const b = parseInt(full.slice(4, 6), 16);
  return `rgba(${r},${g},${b},${a})`;
}

function timeStrToMinutes(timeStr) {
  // "HH:MM" -> minutes from 00:00
  if (!timeStr || typeof timeStr !== "string") return null;
  const m = timeStr.match(/^(\d{2}):(\d{2})$/);
  if (!m) return null;
  const hh = Number(m[1]);
  const mm = Number(m[2]);
  if (hh < 0 || hh > 23 || mm < 0 || mm > 59) return null;
  return hh * 60 + mm;
}

function minutesToTimeStr(mins) {
  const m = ((mins % 1440) + 1440) % 1440;
  const hh = Math.floor(m / 60)
    .toString()
    .padStart(2, "0");
  const mm = Math.floor(m % 60)
    .toString()
    .padStart(2, "0");
  return `${hh}:${mm}`;
}

// --------------------
// Local Storage "DB"
// --------------------
const STORAGE_KEY = "timeplanner_prototype_v1";

function loadStore() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function saveStore(store) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(store));
}

// --------------------
// UI helpers
// --------------------
function PhoneFrame({ children }) {
  return (
    <div className="min-h-screen w-full bg-slate-100 flex items-center justify-center p-4">
      <div className="w-full max-w-[420px]">
        <div className="rounded-[28px] bg-black p-3 shadow-2xl">
          <div className="rounded-[22px] bg-white overflow-hidden">
            {children}
          </div>
        </div>
        <div className="text-xs text-slate-500 mt-3 leading-relaxed">
          * 웹에서 동작하는 프로토타입입니다. 로컬 DB 대신 localStorage를 사용해요.
        </div>
      </div>
    </div>
  );
}

function TopBar({ title, onOpenCategories }) {
  return (
    <div className="px-4 pt-4 pb-3 flex items-center justify-between">
      <div>
        <div className="text-xl font-semibold tracking-tight">{title}</div>
        <div className="text-xs text-slate-500 mt-0.5">
          완료 시간을 기준으로 시작 시간을 계산해요
        </div>
      </div>
      <button
        onClick={onOpenCategories}
        className="h-10 w-10 rounded-full grid place-items-center hover:bg-slate-100 active:bg-slate-200"
        aria-label="카테고리 관리"
        title="카테고리 관리"
      >
        <Settings className="h-5 w-5" />
      </button>
    </div>
  );
}

function Chip({ active, onClick, children }) {
  return (
    <button
      onClick={onClick}
      className={
        "px-3 py-1.5 rounded-full text-sm border transition " +
        (active
          ? "bg-slate-900 text-white border-slate-900"
          : "bg-white text-slate-700 border-slate-200 hover:bg-slate-50 active:bg-slate-100")
      }
    >
      {children}
    </button>
  );
}

function Card({ children, className = "" }) {
  return (
    <div
      className={
        "rounded-2xl border border-slate-200 bg-white shadow-sm " + className
      }
    >
      {children}
    </div>
  );
}

function IconButton({ onClick, label, children }) {
  return (
    <button
      onClick={onClick}
      className="h-9 w-9 rounded-full grid place-items-center hover:bg-slate-100 active:bg-slate-200"
      aria-label={label}
      title={label}
    >
      {children}
    </button>
  );
}

function Modal({ open, title, onClose, children, footer }) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50">
      <div
        className="absolute inset-0 bg-black/40"
        onClick={onClose}
        aria-hidden
      />
      <div className="absolute inset-0 flex items-end justify-center p-4">
        <div className="w-full max-w-[420px] rounded-3xl bg-white shadow-2xl overflow-hidden">
          <div className="px-4 py-3 border-b border-slate-200 flex items-center justify-between">
            <div className="font-semibold">{title}</div>
            <button
              onClick={onClose}
              className="h-9 w-9 rounded-full grid place-items-center hover:bg-slate-100 active:bg-slate-200"
              aria-label="닫기"
            >
              <X className="h-5 w-5" />
            </button>
          </div>
          <div className="p-4 max-h-[70vh] overflow-auto">{children}</div>
          {footer ? (
            <div className="p-4 border-t border-slate-200">{footer}</div>
          ) : null}
        </div>
      </div>
    </div>
  );
}

function PrimaryButton({ onClick, disabled, children }) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={
        "w-full h-11 rounded-2xl font-medium transition " +
        (disabled
          ? "bg-slate-200 text-slate-500"
          : "bg-slate-900 text-white hover:bg-slate-800 active:bg-slate-950")
      }
    >
      {children}
    </button>
  );
}

function SecondaryButton({ onClick, disabled, children }) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={
        "w-full h-11 rounded-2xl font-medium border transition " +
        (disabled
          ? "bg-white text-slate-400 border-slate-200"
          : "bg-white text-slate-800 border-slate-200 hover:bg-slate-50 active:bg-slate-100")
      }
    >
      {children}
    </button>
  );
}

// --------------------
// Sortable items
// --------------------
function SortableRow({ id, children, disabled = false }) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id, disabled });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.85 : 1,
  };

  return (
    <div ref={setNodeRef} style={style}>
      {typeof children === "function"
        ? children({ attributes, listeners })
        : children}
    </div>
  );
}

// --------------------
// Main App
// --------------------
const DEFAULT_COLORS = [
  "#2563EB", // blue
  "#16A34A", // green
  "#DC2626", // red
  "#9333EA", // purple
  "#F59E0B", // amber
  "#0F766E", // teal
];

function seedData() {
  const c1 = { id: uid(), name: "공부", color: DEFAULT_COLORS[0], sortOrder: 0 };
  const c2 = { id: uid(), name: "운동", color: DEFAULT_COLORS[1], sortOrder: 1 };
  const t1 = {
    id: uid(),
    title: "영어 단어 외우기",
    minutes: 20,
    categoryId: c1.id,
    sortOrder: 0,
    createdAt: Date.now(),
  };
  const t2 = {
    id: uid(),
    title: "필기 정리",
    minutes: 30,
    categoryId: c1.id,
    sortOrder: 1,
    createdAt: Date.now(),
  };
  const t3 = {
    id: uid(),
    title: "운동하기",
    minutes: 25,
    categoryId: c2.id,
    sortOrder: 0,
    createdAt: Date.now(),
  };
  const t4 = {
    id: uid(),
    title: "샤워",
    minutes: 10,
    categoryId: null,
    sortOrder: 0,
    createdAt: Date.now(),
  };
  return { categories: [c1, c2], tasks: [t1, t2, t3, t4] };
}

export default function App() {
  const sensors = useSensors(useSensor(PointerSensor, { activationConstraint: { distance: 6 } }));

  const [categories, setCategories] = useState([]);
  const [tasks, setTasks] = useState([]);
  const [filter, setFilter] = useState({ type: "all" }); // all | unassigned | category
  const [endTime, setEndTime] = useState("22:30");

  // Modals
  const [catModalOpen, setCatModalOpen] = useState(false);
  const [taskModalOpen, setTaskModalOpen] = useState(false);

  // Task form state
  const [editingTaskId, setEditingTaskId] = useState(null);
  const [taskTitle, setTaskTitle] = useState("");
  const [taskMinutes, setTaskMinutes] = useState("20");
  const [taskCategoryId, setTaskCategoryId] = useState(null);

  // Category form state
  const [editingCategoryId, setEditingCategoryId] = useState(null);
  const [catName, setCatName] = useState("");
  const [catColor, setCatColor] = useState(DEFAULT_COLORS[0]);

  const [toast, setToast] = useState(null);

  // Load
  useEffect(() => {
    const store = loadStore();
    if (store?.categories && store?.tasks) {
      setCategories(store.categories);
      setTasks(store.tasks);
    } else {
      const seeded = seedData();
      setCategories(seeded.categories);
      setTasks(seeded.tasks);
    }
  }, []);

  // Save
  useEffect(() => {
    if (!categories.length && !tasks.length) return;
    saveStore({ categories, tasks });
  }, [categories, tasks]);

  // Toast helper
  useEffect(() => {
    if (!toast) return;
    const t = setTimeout(() => setToast(null), 2400);
    return () => clearTimeout(t);
  }, [toast]);

  const categoriesSorted = useMemo(() => {
    return [...categories].sort((a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0));
  }, [categories]);

  const categoryMap = useMemo(() => {
    const m = new Map();
    categories.forEach((c) => m.set(c.id, c));
    return m;
  }, [categories]);

  const groupKeyFrom = (categoryId) => (categoryId ? `cat:${categoryId}` : "unassigned");

  const tasksByGroup = useMemo(() => {
    const groups = new Map();
    for (const t of tasks) {
      const key = groupKeyFrom(t.categoryId);
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key).push(t);
    }
    // sort each group by sortOrder
    for (const [k, arr] of groups.entries()) {
      arr.sort((a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0));
      groups.set(k, arr);
    }
    return groups;
  }, [tasks]);

  const filteredGroups = useMemo(() => {
    if (filter.type === "all") {
      // order: categoriesSorted -> their group, then unassigned at end
      const out = [];
      for (const c of categoriesSorted) {
        const key = groupKeyFrom(c.id);
        const arr = tasksByGroup.get(key) || [];
        out.push({ key, title: c.name, color: c.color, categoryId: c.id, tasks: arr });
      }
      const un = tasksByGroup.get("unassigned") || [];
      out.push({ key: "unassigned", title: "미분류", color: "#64748B", categoryId: null, tasks: un });
      return out;
    }
    if (filter.type === "unassigned") {
      const un = tasksByGroup.get("unassigned") || [];
      return [{ key: "unassigned", title: "미분류", color: "#64748B", categoryId: null, tasks: un }];
    }
    if (filter.type === "category") {
      const c = categoryMap.get(filter.categoryId);
      const key = groupKeyFrom(filter.categoryId);
      return [
        {
          key,
          title: c?.name ?? "카테고리",
          color: c?.color ?? "#64748B",
          categoryId: filter.categoryId,
          tasks: tasksByGroup.get(key) || [],
        },
      ];
    }
    return [];
  }, [filter, categoriesSorted, tasksByGroup, categoryMap]);

  const totalMinutes = useMemo(() => {
    const list = filteredGroups.flatMap((g) => g.tasks);
    return list.reduce((sum, t) => sum + (t.minutes || 0), 0);
  }, [filteredGroups]);

  const startTimeResult = useMemo(() => {
    const endM = timeStrToMinutes(endTime);
    if (endM == null) return null;
    const start = endM - totalMinutes;
    const prevDay = start < 0;
    return { time: minutesToTimeStr(start), prevDay };
  }, [endTime, totalMinutes]);

  // --------------------
  // CRUD: Categories
  // --------------------
  function openCategoryModal() {
    setCatModalOpen(true);
    setEditingCategoryId(null);
    setCatName("");
    setCatColor(DEFAULT_COLORS[0]);
  }

  function startEditCategory(cat) {
    setEditingCategoryId(cat.id);
    setCatName(cat.name);
    setCatColor(cat.color || DEFAULT_COLORS[0]);
  }

  function saveCategory() {
    const name = catName.trim();
    if (!name) {
      setToast({ type: "error", msg: "카테고리 이름을 입력해주세요." });
      return;
    }
    const exists = categories.some(
      (c) => c.name.trim().toLowerCase() === name.toLowerCase() && c.id !== editingCategoryId
    );
    if (exists) {
      setToast({ type: "error", msg: "이미 같은 이름의 카테고리가 있어요." });
      return;
    }

    if (editingCategoryId) {
      setCategories((prev) =>
        prev.map((c) =>
          c.id === editingCategoryId ? { ...c, name, color: catColor } : c
        )
      );
      setToast({ type: "ok", msg: "카테고리를 수정했어요." });
    } else {
      const maxOrder = Math.max(-1, ...categories.map((c) => c.sortOrder ?? 0));
      const newCat = {
        id: uid(),
        name,
        color: catColor,
        sortOrder: maxOrder + 1,
      };
      setCategories((prev) => [...prev, newCat]);
      setToast({ type: "ok", msg: "카테고리를 추가했어요." });
    }

    setEditingCategoryId(null);
    setCatName("");
  }

  function deleteCategory(catId) {
    const cat = categories.find((c) => c.id === catId);
    if (!cat) return;
    const ok = window.confirm(
      `"${cat.name}" 카테고리를 삭제할까요?\n(카테고리에 있던 할 일은 "미분류"로 이동해요.)`
    );
    if (!ok) return;

    // Remove category
    setCategories((prev) => {
      const next = prev.filter((c) => c.id !== catId);
      // re-index sortOrder
      return next
        .sort((a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0))
        .map((c, idx) => ({ ...c, sortOrder: idx }));
    });

    // Move tasks to unassigned
    setTasks((prev) =>
      prev.map((t) => (t.categoryId === catId ? { ...t, categoryId: null } : t))
    );

    // If current filter is that category, go back to all
    if (filter.type === "category" && filter.categoryId === catId) {
      setFilter({ type: "all" });
    }

    setToast({ type: "ok", msg: "카테고리를 삭제했어요." });
  }

  function onCategoryDragEnd(event) {
    const { active, over } = event;
    if (!over || active.id === over.id) return;

    setCategories((prev) => {
      const sorted = [...prev].sort((a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0));
      const oldIndex = sorted.findIndex((c) => c.id === active.id);
      const newIndex = sorted.findIndex((c) => c.id === over.id);
      if (oldIndex < 0 || newIndex < 0) return prev;
      const moved = arrayMove(sorted, oldIndex, newIndex).map((c, idx) => ({
        ...c,
        sortOrder: idx,
      }));
      // merge back (since we rewrote sortOrder for all)
      return moved;
    });
  }

  // --------------------
  // CRUD: Tasks
  // --------------------
  function openAddTask(defaultCategoryId = null) {
    setEditingTaskId(null);
    setTaskTitle("");
    setTaskMinutes("20");
    setTaskCategoryId(defaultCategoryId);
    setTaskModalOpen(true);
  }

  function openEditTask(task) {
    setEditingTaskId(task.id);
    setTaskTitle(task.title);
    setTaskMinutes(String(task.minutes));
    setTaskCategoryId(task.categoryId ?? null);
    setTaskModalOpen(true);
  }

  function saveTask() {
    const title = taskTitle.trim();
    if (!title) {
      setToast({ type: "error", msg: "할 일 이름을 입력해주세요." });
      return;
    }

    const mins = clampInt(Number(taskMinutes), 1, 24 * 60);
    if (mins == null) {
      setToast({ type: "error", msg: "소요 시간은 1분 이상 숫자로 입력해주세요." });
      return;
    }

    const groupKey = groupKeyFrom(taskCategoryId);
    const groupTasks = (tasksByGroup.get(groupKey) || []).filter(
      (t) => t.id !== editingTaskId
    );
    const maxOrder = Math.max(-1, ...groupTasks.map((t) => t.sortOrder ?? 0));

    if (editingTaskId) {
      setTasks((prev) => {
        const existing = prev.find((t) => t.id === editingTaskId);
        if (!existing) return prev;

        const prevGroup = groupKeyFrom(existing.categoryId);
        const nextGroup = groupKey;

        // If group changes, assign to end of new group
        const nextSortOrder = prevGroup === nextGroup ? existing.sortOrder : maxOrder + 1;

        return prev.map((t) =>
          t.id === editingTaskId
            ? {
                ...t,
                title,
                minutes: mins,
                categoryId: taskCategoryId,
                sortOrder: nextSortOrder,
              }
            : t
        );
      });
      normalizeTaskOrders();
      setToast({ type: "ok", msg: "할 일을 수정했어요." });
    } else {
      const newTask = {
        id: uid(),
        title,
        minutes: mins,
        categoryId: taskCategoryId,
        sortOrder: maxOrder + 1,
        createdAt: Date.now(),
      };
      setTasks((prev) => [...prev, newTask]);
      setToast({ type: "ok", msg: "할 일을 추가했어요." });
    }

    setTaskModalOpen(false);
  }

  function deleteTask(taskId) {
    const task = tasks.find((t) => t.id === taskId);
    if (!task) return;
    const ok = window.confirm(`"${task.title}"을(를) 삭제할까요?`);
    if (!ok) return;

    setTasks((prev) => prev.filter((t) => t.id !== taskId));
    setTimeout(() => normalizeTaskOrders(), 0);
    setToast({ type: "ok", msg: "할 일을 삭제했어요." });
  }

  function normalizeTaskOrders() {
    // Keep sortOrder contiguous within each group
    setTasks((prev) => {
      const groups = new Map();
      for (const t of prev) {
        const key = groupKeyFrom(t.categoryId);
        if (!groups.has(key)) groups.set(key, []);
        groups.get(key).push(t);
      }
      const next = [];
      for (const [key, arr] of groups.entries()) {
        arr.sort((a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0));
        arr.forEach((t, idx) => next.push({ ...t, sortOrder: idx }));
      }
      return next;
    });
  }

  function onTaskDragEnd(groupKey, event) {
    const { active, over } = event;
    if (!over || active.id === over.id) return;

    setTasks((prev) => {
      // extract group tasks in current order
      const group = prev
        .filter((t) => groupKeyFrom(t.categoryId) === groupKey)
        .sort((a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0));

      const oldIndex = group.findIndex((t) => t.id === active.id);
      const newIndex = group.findIndex((t) => t.id === over.id);
      if (oldIndex < 0 || newIndex < 0) return prev;

      const moved = arrayMove(group, oldIndex, newIndex).map((t, idx) => ({
        ...t,
        sortOrder: idx,
      }));

      // merge: replace only those tasks
      const movedMap = new Map(moved.map((t) => [t.id, t]));
      return prev.map((t) => movedMap.get(t.id) ?? t);
    });
  }

  // --------------------
  // UI Event handlers
  // --------------------
  function handleCalculate() {
    if (timeStrToMinutes(endTime) == null) {
      setToast({ type: "error", msg: "완료 시간을 먼저 선택해주세요." });
      return;
    }
    setToast({ type: "ok", msg: "시작 시간을 계산했어요." });
  }

  function resetData() {
    const ok = window.confirm("샘플 데이터를 다시 만들까요? (현재 데이터가 초기화됩니다)");
    if (!ok) return;
    const seeded = seedData();
    setCategories(seeded.categories);
    setTasks(seeded.tasks);
    setFilter({ type: "all" });
    setEndTime("22:30");
    setToast({ type: "ok", msg: "데이터를 초기화했어요." });
  }

  // --------------------
  // Render
  // --------------------
  return (
    <PhoneFrame>
      <div className="relative">
        <TopBar title="오늘의 작업" onOpenCategories={() => setCatModalOpen(true)} />

        {/* Summary */}
        <div className="px-4">
          <div className="flex items-center gap-2">
            <div className="inline-flex items-center gap-2 rounded-full bg-slate-900 text-white px-3 py-1.5 text-sm">
              <Check className="h-4 w-4" />
              <span>총 소요 시간: {totalMinutes}분</span>
            </div>
            <button
              onClick={resetData}
              className="text-xs text-slate-500 hover:text-slate-700"
            >
              초기화
            </button>
          </div>
        </div>

        {/* Filters */}
        <div className="px-4 mt-3">
          <div className="flex gap-2 overflow-auto pb-2">
            <Chip active={filter.type === "all"} onClick={() => setFilter({ type: "all" })}>
              전체
            </Chip>
            <Chip
              active={filter.type === "unassigned"}
              onClick={() => setFilter({ type: "unassigned" })}
            >
              미분류
            </Chip>
            {categoriesSorted.map((c) => (
              <Chip
                key={c.id}
                active={filter.type === "category" && filter.categoryId === c.id}
                onClick={() => setFilter({ type: "category", categoryId: c.id })}
              >
                <span className="inline-flex items-center gap-2">
                  <span
                    className="h-2.5 w-2.5 rounded-full"
                    style={{ background: c.color }}
                  />
                  {c.name}
                </span>
              </Chip>
            ))}
          </div>
        </div>

        {/* Time cards */}
        <div className="px-4 mt-2 space-y-3">
          <Card className="p-3">
            <div className="flex items-center justify-between gap-3">
              <div>
                <div className="text-sm font-medium">완료 시간</div>
                <div className="text-xs text-slate-500 mt-0.5">
                  끝낼 시간을 선택하세요
                </div>
              </div>
              <input
                type="time"
                value={endTime}
                onChange={(e) => setEndTime(e.target.value)}
                className="h-10 rounded-xl border border-slate-200 px-3 text-sm"
              />
            </div>
          </Card>

          <Card className="p-3">
            <div className="flex items-center justify-between gap-3">
              <div>
                <div className="text-sm font-medium">시작해야 할 시간</div>
                <div className="text-xs text-slate-500 mt-0.5">
                  완료 시간 - 총 소요 시간
                </div>
              </div>
              <div className="text-right">
                <div className="text-lg font-semibold tabular-nums">
                  {startTimeResult ? startTimeResult.time : "--:--"}
                </div>
                {startTimeResult?.prevDay ? (
                  <div className="text-xs text-amber-700">전날</div>
                ) : (
                  <div className="text-xs text-slate-500">&nbsp;</div>
                )}
              </div>
            </div>
            <div className="mt-3">
              <PrimaryButton onClick={handleCalculate}>시작 시간 계산</PrimaryButton>
            </div>
          </Card>
        </div>

        {/* Task list */}
        <div className="px-4 mt-4 pb-24">
          {filteredGroups.every((g) => g.tasks.length === 0) ? (
            <Card className="p-4">
              <div className="text-sm font-medium">아직 할 일이 없어요</div>
              <div className="text-sm text-slate-500 mt-1">
                아래 '할 일 추가'로 시작해보세요.
              </div>
              <div className="mt-3">
                <SecondaryButton
                  onClick={() =>
                    openAddTask(filter.type === "category" ? filter.categoryId : null)
                  }
                >
                  할 일 추가
                </SecondaryButton>
              </div>
            </Card>
          ) : (
            <div className="space-y-4">
              {filteredGroups.map((g) => (
                <GroupSection
                  key={g.key}
                  group={g}
                  sensors={sensors}
                  onDragEnd={(e) => onTaskDragEnd(g.key, e)}
                  onAddTask={() => openAddTask(g.categoryId)}
                  onEditTask={openEditTask}
                  onDeleteTask={deleteTask}
                />
              ))}
            </div>
          )}
        </div>

        {/* Floating Action Button */}
        <button
          onClick={() => openAddTask(filter.type === "category" ? filter.categoryId : null)}
          className="fixed bottom-6 right-6 h-14 w-14 rounded-full bg-slate-900 text-white shadow-xl grid place-items-center hover:bg-slate-800 active:bg-slate-950"
          aria-label="할 일 추가"
          title="할 일 추가"
        >
          <Plus className="h-6 w-6" />
        </button>

        {/* Toast */}
        {toast ? (
          <div className="fixed bottom-24 left-0 right-0 flex justify-center px-4 z-50">
            <div
              className={
                "max-w-[420px] w-full rounded-2xl px-4 py-3 shadow-lg text-sm border " +
                (toast.type === "error"
                  ? "bg-rose-50 border-rose-200 text-rose-800"
                  : "bg-emerald-50 border-emerald-200 text-emerald-800")
              }
            >
              {toast.msg}
            </div>
          </div>
        ) : null}

        {/* Task modal */}
        <Modal
          open={taskModalOpen}
          title={editingTaskId ? "할 일 수정" : "할 일 추가"}
          onClose={() => setTaskModalOpen(false)}
          footer={
            <div className="flex gap-3">
              <SecondaryButton onClick={() => setTaskModalOpen(false)}>취소</SecondaryButton>
              <PrimaryButton onClick={saveTask}>저장</PrimaryButton>
            </div>
          }
        >
          <div className="space-y-4">
            <div>
              <div className="text-sm font-medium">할 일 이름</div>
              <input
                value={taskTitle}
                onChange={(e) => setTaskTitle(e.target.value)}
                placeholder="예: 영어 단어 외우기"
                className="mt-2 w-full h-11 rounded-2xl border border-slate-200 px-3"
              />
            </div>

            <div>
              <div className="text-sm font-medium">소요 시간(분)</div>
              <input
                value={taskMinutes}
                onChange={(e) => setTaskMinutes(e.target.value)}
                inputMode="numeric"
                placeholder="예: 20"
                className="mt-2 w-full h-11 rounded-2xl border border-slate-200 px-3"
              />
              <div className="text-xs text-slate-500 mt-1">1분 이상 입력해주세요.</div>
            </div>

            <div>
              <div className="text-sm font-medium">카테고리</div>
              <select
                value={taskCategoryId ?? ""}
                onChange={(e) => setTaskCategoryId(e.target.value ? e.target.value : null)}
                className="mt-2 w-full h-11 rounded-2xl border border-slate-200 px-3 bg-white"
              >
                <option value="">미분류</option>
                {categoriesSorted.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.name}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </Modal>

        {/* Category modal */}
        <Modal
          open={catModalOpen}
          title="카테고리 관리"
          onClose={() => {
            setCatModalOpen(false);
            setEditingCategoryId(null);
            setCatName("");
          }}
          footer={
            <div className="flex gap-3">
              <SecondaryButton
                onClick={() => {
                  setEditingCategoryId(null);
                  setCatName("");
                }}
              >
                폼 초기화
              </SecondaryButton>
              <PrimaryButton onClick={saveCategory}>
                {editingCategoryId ? "수정 저장" : "추가"}
              </PrimaryButton>
            </div>
          }
        >
          <div className="space-y-4">
            <Card className="p-3">
              <div className="text-sm font-medium">
                {editingCategoryId ? "카테고리 수정" : "카테고리 추가"}
              </div>
              <div className="grid grid-cols-1 gap-3 mt-3">
                <div>
                  <div className="text-xs text-slate-500">이름</div>
                  <input
                    value={catName}
                    onChange={(e) => setCatName(e.target.value)}
                    placeholder="예: 공부"
                    className="mt-2 w-full h-11 rounded-2xl border border-slate-200 px-3"
                  />
                </div>
                <div>
                  <div className="text-xs text-slate-500">색상</div>
                  <div className="mt-2 flex items-center gap-2 flex-wrap">
                    {DEFAULT_COLORS.map((c) => (
                      <button
                        key={c}
                        onClick={() => setCatColor(c)}
                        className={
                          "h-10 w-10 rounded-2xl border grid place-items-center " +
                          (catColor === c
                            ? "border-slate-900"
                            : "border-slate-200 hover:border-slate-300")
                        }
                        style={{ background: hexToRgba(c, 0.18) }}
                        aria-label={`색상 ${c}`}
                      >
                        <span className="h-3 w-3 rounded-full" style={{ background: c }} />
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            </Card>

            <div>
              <div className="text-sm font-medium mb-2">카테고리 목록 (드래그로 순서 변경)</div>
              {categoriesSorted.length === 0 ? (
                <Card className="p-4">
                  <div className="text-sm">카테고리가 없어요</div>
                  <div className="text-sm text-slate-500 mt-1">
                    위에서 카테고리를 추가해보세요.
                  </div>
                </Card>
              ) : (
                <DndContext
                  sensors={sensors}
                  collisionDetection={closestCenter}
                  onDragEnd={onCategoryDragEnd}
                >
                  <SortableContext
                    items={categoriesSorted.map((c) => c.id)}
                    strategy={verticalListSortingStrategy}
                  >
                    <div className="space-y-2">
                      {categoriesSorted.map((c) => (
                        <SortableRow key={c.id} id={c.id}>
                          {({ attributes, listeners }) => (
                            <Card className="p-3">
                              <div className="flex items-center justify-between gap-2">
                                <div className="flex items-center gap-3">
                                  <div
                                    className="h-10 w-10 rounded-2xl grid place-items-center"
                                    style={{ background: hexToRgba(c.color, 0.16) }}
                                  >
                                    <Folder className="h-5 w-5" style={{ color: c.color }} />
                                  </div>
                                  <div>
                                    <div className="font-medium">{c.name}</div>
                                    <div className="text-xs text-slate-500">
                                      포함된 할 일 {tasks.filter((t) => t.categoryId === c.id).length}개
                                    </div>
                                  </div>
                                </div>

                                <div className="flex items-center">
                                  <IconButton
                                    onClick={() => startEditCategory(c)}
                                    label="수정"
                                  >
                                    <Pencil className="h-4 w-4" />
                                  </IconButton>
                                  <IconButton
                                    onClick={() => deleteCategory(c.id)}
                                    label="삭제"
                                  >
                                    <Trash2 className="h-4 w-4" />
                                  </IconButton>
                                  <button
                                    className="h-9 w-9 rounded-full grid place-items-center hover:bg-slate-100 active:bg-slate-200 cursor-grab"
                                    {...attributes}
                                    {...listeners}
                                    aria-label="드래그"
                                    title="드래그"
                                  >
                                    <GripVertical className="h-4 w-4" />
                                  </button>
                                </div>
                              </div>
                            </Card>
                          )}
                        </SortableRow>
                      ))}
                    </div>
                  </SortableContext>
                </DndContext>
              )}
            </div>
          </div>
        </Modal>
      </div>
    </PhoneFrame>
  );
}

function GroupSection({ group, sensors, onDragEnd, onAddTask, onEditTask, onDeleteTask }) {
  const ids = group.tasks.map((t) => t.id);

  return (
    <Card className="p-3">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span
            className="h-2.5 w-2.5 rounded-full"
            style={{ background: group.color }}
          />
          <div className="font-semibold">{group.title}</div>
          <div className="text-xs text-slate-500">{group.tasks.length}개</div>
        </div>
        <button
          onClick={onAddTask}
          className="text-sm font-medium text-slate-700 hover:text-slate-900"
        >
          + 추가
        </button>
      </div>

      {group.tasks.length === 0 ? (
        <div className="mt-3 text-sm text-slate-500">
          할 일이 없어요. "+ 추가"로 등록해보세요.
        </div>
      ) : (
        <div className="mt-3">
          <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={onDragEnd}>
            <SortableContext items={ids} strategy={verticalListSortingStrategy}>
              <div className="space-y-2">
                {group.tasks.map((t) => (
                  <SortableRow key={t.id} id={t.id}>
                    {({ attributes, listeners }) => (
                      <div className="rounded-2xl border border-slate-200 bg-white">
                        <div className="p-3 flex items-center justify-between gap-2">
                          <div className="flex items-center gap-2 min-w-0">
                            <button
                              className="h-9 w-9 rounded-full grid place-items-center hover:bg-slate-100 active:bg-slate-200 cursor-grab flex-none"
                              {...attributes}
                              {...listeners}
                              aria-label="드래그"
                              title="드래그"
                            >
                              <GripVertical className="h-4 w-4" />
                            </button>
                            <div className="min-w-0">
                              <div className="font-medium truncate">{t.title}</div>
                              <div className="text-xs text-slate-500 mt-0.5">
                                {t.minutes}분
                              </div>
                            </div>
                          </div>
                          <div className="flex items-center flex-none">
                            <IconButton onClick={() => onEditTask(t)} label="편집">
                              <Pencil className="h-4 w-4" />
                            </IconButton>
                            <IconButton onClick={() => onDeleteTask(t.id)} label="삭제">
                              <Trash2 className="h-4 w-4" />
                            </IconButton>
                          </div>
                        </div>
                      </div>
                    )}
                  </SortableRow>
                ))}
              </div>
            </SortableContext>
          </DndContext>
        </div>
      )}
    </Card>
  );
}
